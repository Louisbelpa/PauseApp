import Foundation
import ManagedSettings

class ShieldActionExtension: ShieldActionDelegate {

    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // "Non merci" — keep the app blocked, record resistance.
            record(decision: "resisted")
            completionHandler(.close)

        case .secondaryButtonPressed:
            // "Ouvrir quand même" — unblock this specific app, record choice.
            // The main app re-applies blocking next time it enters the foreground.
            record(decision: "opened")
            let store = ManagedSettingsStore()
            if var blocked = store.shield.applications {
                blocked.remove(application)
                store.shield.applications = blocked.isEmpty ? nil : blocked
            }
            completionHandler(.close)

        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(.close)
    }

    // MARK: -

    private func record(decision: String) {
        SharedDefaults.appendEvent(
            SharedEvent(appName: "App", decision: decision, timestamp: Date())
        )
    }
}
