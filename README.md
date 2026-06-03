# PauseApp — iOS

**Introduce intentional friction before opening distracting apps.**

Inspired by "one sec", PauseApp intercepts your habit loops by forcing a brief
breathing pause before you reach for Instagram, TikTok, or any app you've
configured.

---

## Architecture : deux mécanismes d'interception iOS

### Option A — Shortcuts Automation *(référence, non utilisée)*

L'utilisateur crée manuellement une automatisation dans l'app Raccourcis :
> "Quand j'ouvre [Instagram] → Ouvrir PauseApp"

**Avantages :** aucun entitlement spécial, App Store standard.  
**Inconvénients :** setup manuel, contournable, pas d'interception réelle.

---

### Option B — Screen Time API / FamilyControls ✅ **Implémentée**

Via l'entitlement `com.apple.developer.family-controls`, PauseApp bloque
nativement les apps sélectionnées via `ManagedSettingsStore` et affiche
un écran de pause personnalisé (Shield) à chaque tentative d'ouverture.

```
Utilisateur configure ses apps → FamilyActivityPicker
        ↓
ManagedSettingsStore.shield.applications = [tokens]
        ↓
iOS intercepte l'ouverture → ShieldConfigurationExtension
        ↓
Écran de pause PauseApp affiché nativement
        ↓
  [Non merci]           → ShieldActionExtension → .close (app reste bloquée)
  [Ouvrir quand même]   → unblock app + record → main app re-bloque au prochain foreground
```

**Avantages :**
- Interception native — impossible à contourner
- Aucun setup manuel pour l'utilisateur
- Contrôle fin : une app à la fois ou plusieurs

**Inconvénients :**
- Entitlement `com.apple.developer.family-controls` requis (demande au portail Apple Developer)
- Review App Store strict pour les apps Screen Time
- L'UI de pause est une extension système séparée (pas de SwiftUI arbitraire)

---

## Structure

```
PauseApp/                          # App principale
├── App/
│   ├── PauseAppApp.swift          # Entry point, FamilyControls re-apply on foreground
│   └── RootView.swift             # Routing onboarding / main tabs
├── Managers/
│   └── BlockedAppsManager.swift   # @Observable — ManagedSettingsStore + FamilyActivityPicker
├── Models/
│   └── InterventionEvent.swift    # typealias → SharedEvent
├── Features/
│   ├── Onboarding/
│   │   └── OnboardingView.swift   # 3 écrans : concept → auth Screen Time → FamilyActivityPicker
│   ├── Apps/
│   │   └── AppsListView.swift     # FamilyActivityPicker + status carte
│   ├── Dashboard/
│   │   └── DashboardView.swift    # Stats lues depuis SharedDefaults (App Group)
│   └── Settings/
│       └── SettingsView.swift     # Durée pause, haptics, reset stats
└── Design/
    └── Theme.swift

Shared/                            # Compilé dans les 3 targets
└── SharedDefaults.swift           # UserDefaults App Group + SharedEvent Codable

PauseAppShield/                    # Extension : ShieldConfiguration
└── ShieldConfigurationExtension.swift

PauseAppShieldAction/              # Extension : ShieldAction
└── ShieldActionExtension.swift
```

---

## Setup développement

### Prérequis
- Xcode 16+, iOS 17+ device ou simulateur
- XcodeGen (`brew install xcodegen`)
- Entitlement `com.apple.developer.family-controls` accordé dans le portail Apple Developer
- App Group `group.fr.louisbelpa.pauseapp` créé dans le portail

### Installation
```bash
xcodegen generate
open PauseApp.xcodeproj
```

### Note simulateur
`FamilyControls` et `ManagedSettings` nécessitent un **device physique** pour fonctionner
complètement. Sur simulateur, l'autorisation Screen Time échoue silencieusement.

---

## Migration vers Option A (fallback)

Si l'entitlement FamilyControls est refusé :
1. Retirer `BlockedAppsManager.swift` et les deux extensions
2. Restaurer le flux Shortcuts (URL scheme `pauseapp://intervene?app=&scheme=`)
3. `SharedDefaults` + `InterventionEvent` restent inchangés pour les stats
