import SwiftUI
import SwiftData

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            TabView(selection: $page) {
                OnboardingPage1 { withAnimation { page = 1 } }
                    .tag(0)
                OnboardingPage2 { withAnimation { page = 2 } }
                    .tag(1)
                OnboardingPage3 { preset in
                    if let p = preset {
                        modelContext.insert(
                            TrackedApp(name: p.name, urlScheme: p.urlScheme,
                                       sfSymbol: p.sfSymbol, accentHex: p.accentHex)
                        )
                    }
                    onComplete()
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                Spacer()
                PageIndicator(count: 3, current: page)
                    .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Page 1 : concept

struct OnboardingPage1: View {
    let onNext: () -> Void
    @State private var pulsing = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                Circle().fill(Theme.accent.opacity(0.12)).frame(width: 220, height: 220).scaleEffect(pulsing ? 1.1 : 0.9)
                Circle().fill(Theme.accent.opacity(0.25)).frame(width: 150, height: 150).scaleEffect(pulsing ? 1.1 : 0.9)
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.accent)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { pulsing = true }
            }

            VStack(spacing: 14) {
                Text("Tu ouvres Instagram\nsans y penser.")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.text)
                Text("PauseApp t'oblige à choisir.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Theme.textDim)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()
            PrimaryButton(title: "Commencer", action: onNext)
                .padding(.horizontal, 32)
                .padding(.bottom, 80)
        }
    }
}

// MARK: - Page 2 : setup Raccourcis

struct OnboardingPage2: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Comment ça marche")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Theme.text)

            VStack(spacing: 12) {
                SetupStep(number: 1, title: "Ouvre l'app Raccourcis",
                          description: "Intégrée à iOS. Recherche-la avec Spotlight si absente.")
                SetupStep(number: 2, title: "Automatisation → +",
                          description: "Onglet \"Automatisation\" → + → \"Automatisation personnelle\"")
                SetupStep(number: 3, title: "Déclencheur : App",
                          description: "Sélectionne \"Est ouverte\" puis l'app à intercepter")
                SetupStep(number: 4, title: "Action : Ouvrir une URL",
                          description: "Colle le lien PauseApp fourni dans la fiche de l'app")
            }
            .padding(.horizontal, 24)

            Spacer()
            PrimaryButton(title: "Suivant", action: onNext)
                .padding(.horizontal, 32)
                .padding(.bottom, 80)
        }
    }
}

// MARK: - Page 3 : choisir une première app

struct OnboardingPage3: View {
    // nil = skip, non-nil = preset tuple to insert
    let onComplete: ((name: String, urlScheme: String, sfSymbol: String, accentHex: String)?) -> Void

    @State private var selectedName: String? = nil

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Quelle app veux-tu\nmettre en pause ?")
                .font(.system(size: 28, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 32)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(TrackedApp.presets, id: \.name) { preset in
                        PresetAppRow(
                            name: preset.name,
                            sfSymbol: preset.sfSymbol,
                            accentHex: preset.accentHex,
                            isSelected: selectedName == preset.name
                        ) { selectedName = preset.name }
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            let label = selectedName.map { "Ajouter \($0) et continuer" } ?? "Passer pour l'instant"
            PrimaryButton(title: label) {
                let chosen = selectedName.flatMap { name in
                    TrackedApp.presets.first(where: { $0.name == name })
                }
                onComplete(chosen)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Shared sub-views

struct SetupStep: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(Theme.accent).frame(width: 32, height: 32)
                Text("\(number)").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.text)
                Text(description).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.textDim)
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct PresetAppRow: View {
    let name: String
    let sfSymbol: String
    let accentHex: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let color = Color(hex: accentHex)
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.2)).frame(width: 44, height: 44)
                    Image(systemName: sfSymbol).font(.system(size: 20)).foregroundStyle(color)
                }
                Text(name).font(.system(size: 16, weight: .medium)).foregroundStyle(Theme.text)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.accent).font(.system(size: 22))
                }
            }
            .padding(14)
            .background(isSelected ? Theme.accent.opacity(0.12) : Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .strokeBorder(isSelected ? Theme.accent : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

struct PageIndicator: View {
    let count: Int
    let current: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == current ? Theme.accent : Theme.border)
                    .frame(width: i == current ? 20 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }
}
