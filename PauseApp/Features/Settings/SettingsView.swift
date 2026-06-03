import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("animation_duration")        private var animDuration: Double = 4.0
    @AppStorage("haptics_enabled")            private var hapticsEnabled = true
    @AppStorage("estimated_session_minutes") private var estimatedMinutes: Double = 20.0

    @Environment(\.modelContext) private var modelContext
    @Query private var events: [InterventionEvent]

    @State private var showResetConfirm   = false
    @State private var showShortcutsGuide = false

    private let durationOptions: [(label: String, value: Double)] = [
        ("2 secondes", 2.0),
        ("4 secondes (défaut)", 4.0),
        ("6 secondes", 6.0),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    Section {
                        ForEach(durationOptions, id: \.value) { opt in
                            HStack {
                                Text(opt.label).foregroundStyle(Theme.text)
                                Spacer()
                                if animDuration == opt.value {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Theme.accent)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { animDuration = opt.value }
                            .listRowBackground(Theme.surface)
                        }
                    } header: { Text("Durée de la pause").foregroundStyle(Theme.textDim) }

                    Section {
                        Toggle(isOn: $hapticsEnabled) {
                            Text("Vibrations (haptics)").foregroundStyle(Theme.text)
                        }
                        .tint(Theme.accent)
                        .listRowBackground(Theme.surface)

                        HStack {
                            Text("Durée moy. par session").foregroundStyle(Theme.text)
                            Spacer()
                            Stepper("\(Int(estimatedMinutes)) min",
                                    value: $estimatedMinutes, in: 5...120, step: 5)
                                .foregroundStyle(Theme.accent)
                        }
                        .listRowBackground(Theme.surface)
                    } header: { Text("Préférences").foregroundStyle(Theme.textDim) }

                    Section {
                        Button { showShortcutsGuide = true } label: {
                            HStack {
                                Label("Guide Raccourcis", systemImage: "arrow.triangle.branch")
                                    .foregroundStyle(Theme.accent)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.textDim)
                            }
                        }
                        .listRowBackground(Theme.surface)
                    } header: { Text("Aide").foregroundStyle(Theme.textDim) }

                    Section {
                        Button(role: .destructive) { showResetConfirm = true } label: {
                            HStack {
                                Label("Réinitialiser les stats", systemImage: "trash")
                                Spacer()
                                Text("\(events.count) événements")
                                    .font(.system(size: 13)).foregroundStyle(Theme.textDim)
                            }
                        }
                        .listRowBackground(Theme.surface)
                    } header: { Text("Données").foregroundStyle(Theme.textDim) }
                }
                .scrollContentBackground(.hidden)
                .background(Theme.background)
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                "Réinitialiser toutes les statistiques ?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Réinitialiser", role: .destructive) {
                    events.forEach { modelContext.delete($0) }
                }
                Button("Annuler", role: .cancel) {}
            }
            .sheet(isPresented: $showShortcutsGuide) { ShortcutsGeneralGuideView() }
        }
    }
}

struct ShortcutsGeneralGuideView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        SetupStep(number: 1, title: "Ouvre l'app Raccourcis",
                                  description: "Application native iOS. Recherche-la dans Spotlight si besoin.")
                        SetupStep(number: 2, title: "Automatisation → +",
                                  description: "Onglet \"Automatisation\" → + → \"Automatisation personnelle\"")
                        SetupStep(number: 3, title: "Déclencheur : App",
                                  description: "Sélectionne \"Est ouverte\" puis l'app à intercepter")
                        SetupStep(number: 4, title: "Action : Ouvrir une URL",
                                  description: "Colle l'URL PauseApp disponible dans la fiche de l'app (swipe gauche)")
                        SetupStep(number: 5, title: "Désactive la confirmation",
                                  description: "\"Demander avant d'exécuter\" → OFF pour un déclenchement silencieux")
                        SetupStep(number: 6, title: "Test",
                                  description: "Ouvre l'app concernée. PauseApp devrait s'intercaler automatiquement.")
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Guide Raccourcis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }.foregroundStyle(Theme.accent)
                }
            }
        }
    }
}
