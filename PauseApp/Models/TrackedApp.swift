import SwiftData
import SwiftUI

@Model
final class TrackedApp {
    var id: UUID
    var name: String
    var urlScheme: String
    var sfSymbol: String
    var accentHex: String
    var createdAt: Date

    init(name: String, urlScheme: String, sfSymbol: String = "app.fill", accentHex: String = "#6366F1") {
        self.id        = UUID()
        self.name      = name
        self.urlScheme = urlScheme
        self.sfSymbol  = sfSymbol
        self.accentHex = accentHex
        self.createdAt = Date()
    }

    var accentColor: Color { Color(hex: accentHex) }

    var pauseURL: URL? {
        guard
            let encodedScheme = urlScheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let encodedName   = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return nil }
        return URL(string: "pauseapp://intervene?app=\(encodedName)&scheme=\(encodedScheme)")
    }
}

extension TrackedApp {
    // Preset data used during onboarding and suggestions — NOT inserted into the DB automatically.
    static let presets: [(name: String, urlScheme: String, sfSymbol: String, accentHex: String)] = [
        ("Instagram",   "instagram://",  "camera.fill",            "#E1306C"),
        ("TikTok",      "snssdk1233://", "music.note",             "#010101"),
        ("Twitter / X", "twitter://",    "bird.fill",              "#1DA1F2"),
        ("YouTube",     "youtube://",    "play.rectangle.fill",    "#FF0000"),
        ("LinkedIn",    "linkedin://",   "briefcase.fill",         "#0A66C2"),
        ("Reddit",      "reddit://",     "bubble.left.fill",       "#FF4500"),
    ]
}
