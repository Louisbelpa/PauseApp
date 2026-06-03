import SwiftUI

@main
struct PauseAppApp: App {
    @State private var manager = BlockedAppsManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(manager)
                // Re-block apps that were temporarily unblocked by ShieldAction.
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.willEnterForegroundNotification
                    )
                ) { _ in manager.reapply() }
        }
    }
}
