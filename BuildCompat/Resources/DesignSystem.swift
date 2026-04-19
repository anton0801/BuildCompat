import SwiftUI

// MARK: - Color System
extension Color {
    // Backgrounds
//    static let bcBackground = Color("BCBackground")
//    static let bcBackgroundSecondary = Color("BCBackgroundSecondary")
//    static let bcCard = Color("BCCard")

    // Accent
    static let bcAccent = Color(hex: "#3B82F6")
    static let bcAccentActive = Color(hex: "#2563EB")
    static let bcAccentSoft = Color(hex: "#60A5FA")

    // Material colors
    static let bcConcrete = Color(hex: "#9CA3AF")
    static let bcWood = Color(hex: "#C08457")
    static let bcTile = Color(hex: "#60A5FA")
    static let bcMetal = Color(hex: "#94A3B8")
    static let bcPaint = Color(hex: "#F472B6")
    static let bcAdhesive = Color(hex: "#A78BFA")

    // Status
    static let bcCompatible = Color(hex: "#22C55E")
    static let bcWarning = Color(hex: "#FACC15")
    static let bcIncompatible = Color(hex: "#EF4444")

    // Text
//    static let bcTextPrimary = Color("BCTextPrimary")
//    static let bcTextSecondary = Color("BCTextSecondary")
    static let bcTextMuted = Color(hex: "#94A3B8")

    // Borders
    static let bcBorder = Color(hex: "#E2E8F0")
    static let bcDivider = Color(hex: "#CBD5E1")

    // Button secondary
//    static let bcButtonSecondary = Color("BCButtonSecondary")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Typography
struct BCFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func heading(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

// MARK: - Shadows
extension View {
    func bcCardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    func bcStatusGlow(_ color: Color) -> some View {
        self.shadow(color: color.opacity(0.4), radius: 16, x: 0, y: 0)
    }
}

// MARK: - Animations
extension Animation {
    static let bcSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let bcQuick = Animation.spring(response: 0.25, dampingFraction: 0.8)
}

// MARK: - Button Styles
struct BCPrimaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BCFont.body(16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDestructive ? Color.bcIncompatible : Color.bcAccent)
                    .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.bcQuick, value: configuration.isPressed)
    }
}

struct BCSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BCFont.body(16, weight: .medium))
            .foregroundColor(.bcTextPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.bcButtonSecondary)
                    .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.bcQuick, value: configuration.isPressed)
    }
}

// MARK: - Card View Modifier
struct BCCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.bcCard)
            .cornerRadius(16)
            .bcCardShadow()
    }
}

extension View {
    func bcCard() -> some View {
        modifier(BCCardModifier())
    }
}
