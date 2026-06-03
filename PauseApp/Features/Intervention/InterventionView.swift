import SwiftUI
import SwiftData

struct InterventionView: View {
    let appName: String
    let appScheme: String
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL)      private var openURL
    @AppStorage("animation_duration")  private var animDuration: Double = 4.0
    @AppStorage("haptics_enabled")     private var hapticsEnabled = true

    @Query private var trackedApps: [TrackedApp]

    @State private var progress: Double = 0
    @State private var animationDone = false

    private var accentColor: Color {
        trackedApps.first(where: { $0.urlScheme == appScheme })?.accentColor ?? Theme.accent
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Countdown ring
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Theme.border, lineWidth: 2.5)
                            .frame(width: 38, height: 38)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(accentColor,
                                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                            .frame(width: 38, height: 38)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.05), value: progress)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                Spacer()

                BreathingCircleView(cycleDuration: animDuration, accentColor: accentColor)

                VStack(spacing: 8) {
                    Text("Tu allais ouvrir")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textDim)
                    Text(appName)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Text("Pourquoi ?")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textDim)
                }
                .padding(.top, 40)

                Spacer()

                if animationDone {
                    VStack(spacing: 12) {
                        Button { resist() } label: {
                            Text("Non merci")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        }
                        Button { openApp() } label: {
                            Text("Ouvrir quand même")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Theme.textDim)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        }
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Color.clear.frame(height: 48)
            }
        }
        // Countdown ticker — .task auto-cancels on disappear.
        .task {
            let tickInterval = 0.05
            let ticks = Int(ceil(animDuration / tickInterval))
            for i in 1...ticks {
                try? await Task.sleep(for: .seconds(tickInterval))
                progress = min(1.0, Double(i) * tickInterval / animDuration)
            }
            withAnimation(.spring(duration: 0.5)) { animationDone = true }
            if hapticsEnabled {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    private func resist() {
        record(.resisted)
        impact(.success)
        onDismiss()
    }

    private func openApp() {
        record(.opened)
        impact(.warning)
        if let url = URL(string: appScheme) { openURL(url) }
        onDismiss()
    }

    private func record(_ decision: InterventionDecision) {
        modelContext.insert(InterventionEvent(appName: appName, appScheme: appScheme, decision: decision))
    }

    private func impact(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
