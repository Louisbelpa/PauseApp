import SwiftUI
import SwiftData

struct AddEditAppView: View {
    var app: TrackedApp? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss)      private var dismiss

    @State private var name      = ""
    @State private var urlScheme = ""
    @State private var sfSymbol  = "app.fill"
    @State private var accentHex = "#6366F1"

    private let symbolOptions = [
        "app.fill", "camera.fill", "music.note", "play.rectangle.fill",
        "briefcase.fill", "bubble.left.fill", "globe", "person.fill",
        "heart.fill", "star.fill", "bolt.fill", "flame.fill",
        "gamecontroller.fill", "cart.fill", "airplane", "car.fill",
    ]
    private let colorOptions = [
        "#6366F1", "#E1306C", "#1DA1F2", "#FF0000",
        "#0A66C2", "#FF4500", "#22C55E", "#F59E0B",
        "#8B5CF6", "#EC4899", "#06B6D4", "#FFFFFF",
    ]

    private var isEditing: Bool { app != nil }
    private var canSave:   Bool { !name.isEmpty && !urlScheme.isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        AppPreviewCard(name: name.isEmpty ? "Nom de l'app" : name,
                                       sfSymbol: sfSymbol, accentHex: accentHex)
                            .padding(.top, 8)

                        VStack(spacing: 16) {
                            FormField(label: "Nom", placeholder: "Instagram", text: $name)
                            FormField(label: "URL Scheme", placeholder: "instagram://", text: $urlScheme)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }

                        if !isEditing {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionLabel("Suggestions")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(TrackedApp.presets, id: \.name) { p in
                                            Button {
                                                name = p.name; urlScheme = p.urlScheme
                                                sfSymbol = p.sfSymbol; accentHex = p.accentHex
                                            } label: {
                                                HStack(spacing: 6) {
                                                    Image(systemName: p.sfSymbol)
                                                    Text(p.name)
                                                }
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(Theme.text)
                                                .padding(.horizontal, 12).padding(.vertical, 8)
                                                .background(Theme.surface).clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Icône")
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                ForEach(symbolOptions, id: \.self) { sym in
                                    Button { sfSymbol = sym } label: {
                                        Image(systemName: sym)
                                            .font(.system(size: 20))
                                            .foregroundStyle(sfSymbol == sym ? Theme.background : Theme.text)
                                            .frame(width: 40, height: 40)
                                            .background(sfSymbol == sym ? Color(hex: accentHex) : Theme.surface)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Couleur accent")
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(colorOptions, id: \.self) { hex in
                                    Button { accentHex = hex } label: {
                                        ZStack {
                                            Circle().fill(Color(hex: hex)).frame(width: 40, height: 40)
                                            if accentHex == hex {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(hex == "#FFFFFF" ? .black : .white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle(isEditing ? "Modifier" : "Nouvelle app")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }.foregroundStyle(Theme.textDim)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enregistrer") { save() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canSave ? Theme.accent : Theme.textDim)
                        .disabled(!canSave)
                }
            }
        }
        .onAppear {
            guard let app else { return }
            name = app.name; urlScheme = app.urlScheme
            sfSymbol = app.sfSymbol; accentHex = app.accentHex
        }
    }

    private func save() {
        if let app {
            app.name = name; app.urlScheme = urlScheme
            app.sfSymbol = sfSymbol; app.accentHex = accentHex
        } else {
            modelContext.insert(TrackedApp(name: name, urlScheme: urlScheme,
                                           sfSymbol: sfSymbol, accentHex: accentHex))
        }
        dismiss()
    }
}

// MARK: - Sub-views (reused in ShortcutsGuideView)

struct AppPreviewCard: View {
    let name: String
    let sfSymbol: String
    let accentHex: String
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: accentHex).opacity(0.2)).frame(width: 56, height: 56)
                Image(systemName: sfSymbol).font(.system(size: 26)).foregroundStyle(Color(hex: accentHex))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.system(size: 18, weight: .semibold)).foregroundStyle(Theme.text)
                Text("Aperçu").font(.system(size: 13)).foregroundStyle(Theme.textDim)
            }
            Spacer()
        }
        .padding(16).background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(label)
            TextField(placeholder, text: $text)
                .font(.system(size: 16)).foregroundStyle(Theme.text)
                .padding(14).background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Theme.textDim)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}
