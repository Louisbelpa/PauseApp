import SwiftData
import Foundation

enum InterventionDecision: String, Codable {
    case opened   // "Ouvrir quand même"
    case resisted // "Non merci"
}

@Model
final class InterventionEvent {
    var id: UUID
    var appName: String
    var appScheme: String
    var decisionRaw: String
    var timestamp: Date

    init(appName: String, appScheme: String, decision: InterventionDecision) {
        self.id          = UUID()
        self.appName     = appName
        self.appScheme   = appScheme
        self.decisionRaw = decision.rawValue
        self.timestamp   = Date()
    }

    var decision: InterventionDecision {
        InterventionDecision(rawValue: decisionRaw) ?? .opened
    }

    var resisted: Bool { decision == .resisted }
}
