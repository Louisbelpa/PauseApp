import Foundation

// Shared UserDefaults container used by the main app AND both extensions.
// All three targets include this file via project.yml `sources: [Shared]`.
enum SharedDefaults {
    static let suiteName = "group.fr.louisbelpa.pauseapp"

    static var store: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static let selectionKey = "blocked_apps_selection"
    static let eventsKey    = "intervention_events"

    static func appendEvent(_ event: SharedEvent) {
        var list = loadEvents()
        list.append(event)
        store.set(try? JSONEncoder().encode(list), forKey: eventsKey)
    }

    static func loadEvents() -> [SharedEvent] {
        guard
            let data = store.data(forKey: eventsKey),
            let list = try? JSONDecoder().decode([SharedEvent].self, from: data)
        else { return [] }
        return list
    }

    static func clearEvents() {
        store.removeObject(forKey: eventsKey)
    }
}

struct SharedEvent: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var appName: String
    var decision: String   // "resisted" | "opened"
    var timestamp: Date

    var resisted: Bool { decision == "resisted" }
}
