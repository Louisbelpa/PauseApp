import SwiftUI

struct SettingsView: View {
    @AppStorage("animation_duration")        private var animDuration: Double  = 4.0
    @AppStorage("haptics_enabled")           private var hapticsEnabled        = true
    @AppStorage("estimated_session_minutes") private var estimatedMinutes: Double = 20.0

    @State private var showResetConfirm = false
    @State private var eventCount       = 0
    @Environment(BlockedAppsManager.self) private var manager

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
                        HStack {
                            Label("Protection", systemImage: manager.activitySelection.applicationTokens.isEmpty
                                  ? "shield.slash" : "shield.checkered")
                                .foregroundStyle(manager.activitySelection.applicationTokens.isEmpty
                                                 ? Theme.textDim : Theme.green)
                            Spacer()
                            Text(manager.activitySelection.applicationTokens.isEmpty
                                 ? "Inactive" : "\(manager.activitySelection.applicationTokens.count) app(s)")
                                .font(.system(size: 13)).foregroundStyle(Theme.textDim)
                        }
                        .listRowBackground(Theme.surface)
                    } header: { Text("Screen Time").foregroundStyle(Theme.textDim) }

                    Section {
                        Button(role: .destructive) { showResetConfirm = true } label: {
                            HStack {
                                Label("Réinitialiser les stats", systemImage: "trash")
                                Spacer()
                                Text("\(eventCount) événements")
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
            .onAppear { eventCount = SharedDefaults.loadEvents().count }
            .confirmationDialog(
                "Réinitialiser toutes les statistiques ?",
                isPresented: $showResetConfirm, titleVisibility: .visible
            ) {
                Button("Réinitialiser", role: .destructive) {
                    SharedDefaults.clearEvents()
                    eventCount = 0
                }
                Button("Annuler", role: .cancel) {}
            }
        }
    }
}
