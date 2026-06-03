# PauseApp — iOS

**Introduce intentional friction before opening distracting apps.**

Inspired by "one sec", PauseApp intercepts your habit loops by forcing a brief
breathing pause before you reach for Instagram, TikTok, or any app you've
configured.

---

## Architecture : deux mécanismes d'interception iOS

### Option A — Shortcuts Automation ✅ MVP actuel

**Comment ça marche :**
L'utilisateur crée manuellement une automatisation dans l'app Raccourcis :
> "Quand j'ouvre [Instagram] → Ouvrir PauseApp"

PauseApp reçoit l'app cible via une URL scheme (`pauseapp://intervene?app=Instagram&scheme=instagram://`),
joue l'animation de pause (N secondes de respiration), puis propose deux choix :
- **Non merci** — retourne à l'écran d'accueil iOS
- **Ouvrir quand même** — redirige vers l'app cible via son URL scheme

```
Utilisateur tape sur l'icône Instagram
        ↓
Raccourcis détecte l'ouverture de l'app
        ↓
Raccourcis lance PauseApp via URL scheme
        ↓
PauseApp joue l'animation + recueille la décision
        ↓
  [Non merci]          → minimize app, retour accueil
  [Ouvrir quand même]  → openURL("instagram://")
```

**Avantages :**
- Aucun entitlement spécial Apple requis
- App Store friendly, review standard
- Fonctionne dès iOS 13+
- Aucun accès aux données privées de l'utilisateur

**Inconvénients :**
- Setup manuel (l'utilisateur doit créer chaque automatisation Raccourcis)
- Contournable (désactiver l'automatisation dans Raccourcis)
- L'automatisation peut demander confirmation selon les réglages iOS
- Nom de l'app visible brièvement dans la barre de notification Raccourcis

---

### Option B — Screen Time API / FamilyControls

**Comment ça marche :**
Via l'entitlement `com.apple.developer.family-controls`, l'app accède aux
frameworks `ManagedSettings` et `DeviceActivity` pour bloquer ou modifier
programmatiquement le comportement des apps.

```swift
// Requiert FamilyControls entitlement
import ManagedSettings
import DeviceActivity

// Bloquer une app jusqu'à intervention
let store = ManagedSettingsStore()
store.application.blockedApplications = [selectedApp]

// Extension DeviceActivityMonitor — déclenchée par schedule
class MyMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        // Présenté par le système, pas l'app principale
    }
}
```

**Avantages :**
- Interception native, impossible à contourner
- Pas de setup manuel pour l'utilisateur
- Contrôle fin sur les apps (blocage total, partiel, temporisé)

**Inconvénients :**
- Entitlement `com.apple.developer.family-controls` difficile à obtenir pour
  les développeurs indépendants (Apple impose un use case justifié)
- Review App Store strict — catégorie "contrôle parental" uniquement
- Ne peut pas simplement "mettre en pause" — doit bloquer/débloquer
- L'UI de blocage est une extension système séparée (pas dans l'app principale)

---

## Architecture MVP (Option A)

```
PauseApp/
├── App/
│   ├── PauseAppApp.swift          # Entry point + URL scheme handler
│   └── RootView.swift             # Onboarding vs main nav routing
├── Models/
│   ├── TrackedApp.swift           # SwiftData model : app configurée
│   └── InterventionEvent.swift    # SwiftData model : événement enregistré
├── Features/
│   ├── Onboarding/
│   │   └── OnboardingView.swift   # 3 écrans d'intro
│   ├── Intervention/
│   │   ├── InterventionView.swift     # Écran de pause (cœur de l'app)
│   │   └── BreathingCircleView.swift  # Animation cercle respiratoire
│   ├── Apps/
│   │   ├── AppsListView.swift     # Liste + CRUD apps configurées
│   │   ├── AddEditAppView.swift   # Formulaire ajout/modification
│   │   └── ShortcutsGuideView.swift # Instructions Raccourcis par app
│   ├── Dashboard/
│   │   └── DashboardView.swift    # Stats + graphiques 7 jours
│   └── Settings/
│       └── SettingsView.swift     # Préférences utilisateur
└── Design/
    └── Theme.swift                # Constantes design system
```

### URL scheme

L'app enregistre le scheme `pauseapp://` dans `Info.plist`.

Format d'entrée depuis Raccourcis :
```
pauseapp://intervene?app=Instagram&scheme=instagram%3A%2F%2F
```

| Param | Description | Exemple |
|-------|-------------|--------|
| `app` | Nom affiché | `Instagram` |
| `scheme` | URL scheme cible (URL-encoded) | `instagram://` |

### Migration vers Option B

Pour migrer vers FamilyControls ultérieurement :
1. Obtenir l'entitlement Apple + ajouter la target `DeviceActivityMonitor`
2. Remplacer le déclencheur Raccourcis par `ManagedSettingsStore` + `DeviceActivitySchedule`
3. `InterventionView` reste intact — seul le déclencheur change
4. `InterventionEvent` + `TrackedApp` SwiftData sont inchangés

---

## Setup développement

### Prérequis
- Xcode 16+
- iOS 17+ simulator ou device
- XcodeGen (`brew install xcodegen`)

### Installation
```bash
cd PauseApp
xcodegen generate
open PauseApp.xcodeproj
```

### Tester l'écran d'intervention
Dans Safari (simulateur iOS) :
```
pauseapp://intervene?app=Instagram&scheme=instagram%3A%2F%2F
```

---

## Apps préconfigurées

| App | URL Scheme |
|-----|----------|
| Instagram | `instagram://` |
| TikTok | `snssdk1233://` |
| Twitter / X | `twitter://` |
| YouTube | `youtube://` |
| LinkedIn | `linkedin://` |
| Reddit | `reddit://` |
