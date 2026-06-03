import SwiftUI

struct BreathingCircleView: View {
    let cycleDuration: Double
    let accentColor: Color

    @State private var expanded = false
    @State private var phaseLabel = "Inspirez..."

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.08))
                    .frame(width: 240, height: 240)
                    .scaleEffect(expanded ? 1.0 : 0.7)
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .scaleEffect(expanded ? 1.0 : 0.7)
                Circle()
                    .fill(accentColor.opacity(0.42))
                    .frame(width: 120, height: 120)
                    .scaleEffect(expanded ? 1.0 : 0.7)
                Image(systemName: "wind")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(.white.opacity(0.85))
            }
            Text(phaseLabel)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Theme.textDim)
                .animation(.easeInOut(duration: 0.4), value: phaseLabel)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: cycleDuration / 2)
                .repeatForever(autoreverses: true)
            ) { expanded = true }
        }
        // Toggle phase label using Swift Concurrency — .task auto-cancels on disappear.
        .task {
            let half = cycleDuration / 2
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(half))
                phaseLabel = "Expirez..."
                try? await Task.sleep(for: .seconds(half))
                phaseLabel = "Inspirez..."
            }
        }
    }
}
