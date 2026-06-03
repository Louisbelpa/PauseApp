import SwiftUI

enum Theme {
    static let background = Color(hex: "#0A0A0F")
    static let surface    = Color(hex: "#13131A")
    static let border     = Color(hex: "#1E1E2A")
    static let accent     = Color(hex: "#6366F1")
    static let text       = Color.white
    static let textDim    = Color(hex: "#6B7280")
    static let green      = Color(hex: "#22C55E")
    static let red        = Color(hex: "#EF4444")
    static let amber      = Color(hex: "#F59E0B")

    static let cornerRadius: CGFloat = 16
    static let animDuration: Double  = 0.4
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
