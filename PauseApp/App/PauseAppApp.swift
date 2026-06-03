import SwiftUI
import SwiftData

@main
struct PauseAppApp: App {
    @State private var interventionTarget: InterventionTarget?

    var body: some Scene {
        WindowGroup {
            RootView(interventionTarget: $interventionTarget)
                .modelContainer(for: [TrackedApp.self, InterventionEvent.self])
                .onOpenURL { url in
                    interventionTarget = InterventionTarget(url: url)
                }
        }
    }
}

// Parsed payload from pauseapp://intervene?app=...&scheme=...
struct InterventionTarget: Identifiable {
    let id = UUID()
    let appName: String
    let appScheme: String

    init?(url: URL) {
        guard
            url.scheme == "pauseapp",
            url.host == "intervene",
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let name   = items.first(where: { $0.name == "app" })?.value,
            let scheme = items.first(where: { $0.name == "scheme" })?.value
        else { return nil }
        self.appName   = name
        self.appScheme = scheme
    }
}
