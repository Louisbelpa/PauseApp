import Foundation
import FamilyControls
import ManagedSettings
import Observation

@Observable
@MainActor
final class BlockedAppsManager {
    var activitySelection = FamilyActivitySelection()
    var authorizationStatus: AuthStatus = .notDetermined
    var isAuthorizing = false

    enum AuthStatus { case notDetermined, authorized, denied }

    private let store = ManagedSettingsStore()

    init() { loadPersistedSelection() }

    func requestAuthorization() async {
        isAuthorizing = true
        defer { isAuthorizing = false }
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = .authorized
        } catch {
            authorizationStatus = .denied
        }
    }

    // Pushes current selection into ManagedSettingsStore (blocks chosen apps).
    func applyBlocking() {
        let tokens = activitySelection.applicationTokens
        store.shield.applications = tokens.isEmpty ? nil : tokens
        persistSelection()
    }

    func clearBlocking() {
        store.shield.applications = nil
        activitySelection = FamilyActivitySelection()
        persistSelection()
    }

    // Called on willEnterForeground to re-block any app temporarily unblocked by ShieldAction.
    func reapply() {
        loadPersistedSelection()
        applyBlocking()
    }

    // MARK: - Persistence

    private func persistSelection() {
        SharedDefaults.store.set(
            try? JSONEncoder().encode(activitySelection),
            forKey: SharedDefaults.selectionKey
        )
    }

    private func loadPersistedSelection() {
        guard
            let data = SharedDefaults.store.data(forKey: SharedDefaults.selectionKey),
            let s    = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }
        activitySelection = s
    }
}
