import SwiftUI

struct ShortcutsGuideView: View {
    let app: TrackedApp
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        AppPreviewCard(name: app.name, sfSymbol: app.sfSymbol, accentHex: app.accentHex)

                        // Deep link to copy
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Lien à copier dans Raccourcis")
                            if let url = app.pauseURL {
                                HStack(spacing: 12) {
                                    Text(url.absoluteString)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundStyle(Theme.accent)
                                        .lineLimit(3)
                                    Spacer()
                                    Button {
                                        UIPasteboard.general.string = url.absoluteString
                                        copied = true
                                        Task { try? await Task.sleep(for: .seconds(2)); copied = false }
                                    } label: {
                                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                            .foregroundStyle(copied ? Theme.green : Theme.accent)
                                            .font(.system(size: 18))
                                            .animation(.easeInOut(duration: 0.2), value: copied)
                                    }
                                }
                                .padding(14)
                                .background(Theme.accent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        // Steps
                        VStack(alignment: .leading, spacing: 12) {
                            SectionLabel("Étapes Raccourcis")
                            SetupStep(number: 1, title: "Ouvre Raccourcis",
                                      description: "L'app Raccourcis est native iOS (disponible sur l'App Store si absente)")
                            SetupStep(number: 2, title: "Automatisation → +",
                                      description: "\"Automatisation personnelle\" dans l'onglet Automatisation")
                            SetupStep(number: 3, title: "Déclencheur : App → \(app.name)",
                                      description: "Coche \"Est ouverte\" puis sélectionne \(app.name)")
                            SetupStep(number: 4, title: "Action : Ouvrir une URL",
                                      description: "Recherche l'action \"Ouvrir une URL\" et colle le lien ci-dessus")
                            SetupStep(number: 5, title: "Désactive la confirmation",
                                      description: "Passe \"Demander avant d'exécuter\" sur OFF pour un déclenchement silencieux")
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Setup Raccourcis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }.foregroundStyle(Theme.accent)
                }
            }
        }
    }
}
