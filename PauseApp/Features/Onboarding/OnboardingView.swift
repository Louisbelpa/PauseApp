import SwiftUI
import FamilyControls

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0
    @Environment(BlockedAppsManager.self) private var manager

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            TabView(selection: $page) {
                OnboardingPage1 { withAnimation { page = 1 } }
                    .tag(0)
                OnboardingPage2 {
                    Task {
                        if manager.authorizationStatus != .authorized {
                            await manager.requestAuthorization()
                        }
                        withAnimation { page = 2 }
                    }
                }
                .tag(1)
                OnboardingPage3(onComplete: onComplete)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                Spacer()
                PageIndicator(count: 3, current: page).padding(.bottom, 40)
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
                Circle().fill(Theme.accent.opacity(0.12)).frame(width: 220, height: 220)
                    .scaleEffect(pulsing ? 1.1 : 0.9)
                Circle().fill(Theme.accent.opacity(0.25)).frame(width: 150, height: 150)
                    .scaleEffect(pulsing ? 1.1 : 0.9)
                Image(systemName: "pause.circle.fill").font(.system(size: 64)).foregroundStyle(Theme.accent)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { pulsing = true }
            }
            VStack(spacing: 14) {
                Text("Tu ouvres Instagram\nsans y penser.")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center).foregroundStyle(Theme.text)
                Text("PauseApp t'oblige à choisir.")
                    .font(.system(size: 17, weight: .medium)).foregroundStyle(Theme.textDim)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            Spacer()
            PrimaryButton(title: "Commencer", action: onNext)
                .padding(.horizontal, 32).padding(.bottom, 80)
        }
    }
}

// MARK: - Page 2 : autorisation Screen Time

struct OnboardingPage2: View {
    let onNext: () -> Void
    @Environment(BlockedAppsManager.self) private var manager

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 64)).foregroundStyle(Theme.accent)

            VStack(spacing: 14) {
                Text("Temps d'écran")
                    .font(.system(size: 28, weight: .semibold)).foregroundStyle(Theme.text)
                Text("PauseApp utilise l'API Screen Time d'Apple pour bloquer nativement les apps et afficher un écran de pause à chaque tentative d'ouverture.")
                    .font(.system(size: 16, weight: .medium)).foregroundStyle(Theme.textDim)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 10) {
                InfoRow(icon: "lock.shield.fill",  color: Theme.green,
                        text: "Interception native — impossible à contourner")
                InfoRow(icon: "hand.raised.fill",  color: Theme.accent,
                        text: "Tout reste sur ton appareil, rien n'est envoyé")
                InfoRow(icon: "gearshape.2.fill",  color: Theme.amber,
                        text: "Nécessite l'autorisation Screen Time d'iOS")
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton(
                title: manager.isAuthorizing ? "Demande en cours..." : "Autoriser Screen Time",
                action: onNext
            )
            .padding(.horizontal, 32).padding(.bottom, 80)
            .opacity(manager.isAuthorizing ? 0.6 : 1)
            .disabled(manager.isAuthorizing)
        }
    }
}

// MARK: - Page 3 : choisir les apps via FamilyActivityPicker

struct OnboardingPage3: View {
    let onComplete: () -> Void
    @Environment(BlockedAppsManager.self) private var manager
    @State private var showingPicker = false

    var count: Int { manager.activitySelection.applicationTokens.count }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "apps.iphone.badge.plus")
                .font(.system(size: 64)).foregroundStyle(Theme.accent)

            VStack(spacing: 14) {
                Text("Choisir les apps\nà mettre en pause")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center).foregroundStyle(Theme.text)
                Text("Sélectionne une ou plusieurs apps. À chaque tentative d'ouverture, l'écran de pause s'affichera.")
                    .font(.system(size: 16, weight: .medium)).foregroundStyle(Theme.textDim)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            if count > 0 {
                Text("\(count) app\(count > 1 ? "s" : "") sélectionnée\(count > 1 ? "s" : "")")
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.green)
            }

            Spacer()

            VStack(spacing: 12) {
                @Bindable var bManager = manager
                PrimaryButton(title: "Choisir les apps") { showingPicker = true }
                    .familyActivityPicker(
                        isPresented: $showingPicker,
                        selection: $bManager.activitySelection
                    )

                if count > 0 {
                    Button("Terminer →") {
                        manager.applyBlocking()
                        onComplete()
                    }
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(Theme.accent)
                } else {
                    Button("Passer pour l'instant") { onComplete() }
                        .font(.system(size: 15)).foregroundStyle(Theme.textDim)
                }
            }
            .padding(.horizontal, 32).padding(.bottom, 80)
        }
    }
}

// MARK: - Shared sub-views

struct InfoRow: View {
    let icon: String; let color: Color; let text: String
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 20)).foregroundStyle(color).frame(width: 28)
            Text(text).font(.system(size: 15, weight: .medium)).foregroundStyle(Theme.textDim)
            Spacer()
        }
        .padding(14).background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct SetupStep: View {
    let number: Int; let title: String; let description: String
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
        .padding(14).background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct PageIndicator: View {
    let count: Int; let current: Int
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
    let title: String; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }
}
