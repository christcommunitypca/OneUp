import SwiftUI

// MARK: - Theme

enum Theme {
    // Spring/Summer Senior palette
    static let background = LinearGradient(
        colors: [Color(hex: "FFF0F8"), Color(hex: "F0FDF4"), Color(hex: "FEFCE8")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let pink       = Color(hex: "F472B6")
    static let pinkLight  = Color(hex: "FCE7F3")
    static let violet     = Color(hex: "8B5CF6")
    static let violetLight = Color(hex: "EDE9FE")
    static let mint       = Color(hex: "10B981")
    static let mintLight  = Color(hex: "D1FAE5")
    static let gold       = Color(hex: "F59E0B")
    static let coral      = Color(hex: "F97316")
    static let red        = Color(hex: "EF4444")
    static let text       = Color(hex: "1F1035")
    static let gray       = Color(hex: "6B7280")
    static let lightGray  = Color(hex: "F3F4F6")
    static let white      = Color.white

    static let cardShadow  = Color.black.opacity(0.08)
    static let panelRadius: CGFloat = 16
    static let tileRadius:  CGFloat = 12
}

// MARK: - Color hex init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Player palette

let playerPalette: [Color] = [
    Theme.pink, Theme.violet, Theme.mint, Theme.gold,
    Theme.coral, Color(hex: "06B6D4"), Color(hex: "84CC16"),
    Color(hex: "EC4899"), Color(hex: "F97316"), Color(hex: "6366F1")
]

func playerColor(_ index: Int) -> Color {
    playerPalette[index % playerPalette.count]
}

// MARK: - View Modifiers

struct PanelStyle: ViewModifier {
    var highlighted = false
    var color: Color = Theme.violet

    func body(content: Content) -> some View {
        content
            .background(Theme.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.panelRadius))
            .shadow(color: highlighted ? color.opacity(0.18) : Theme.cardShadow, radius: highlighted ? 12 : 6)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.panelRadius)
                    .stroke(highlighted ? color : Color.clear, lineWidth: 2)
            )
    }
}

extension View {
    func panelStyle(highlighted: Bool = false, color: Color = Theme.violet) -> some View {
        modifier(PanelStyle(highlighted: highlighted, color: color))
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    var color: Color = Theme.violet
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(disabled ? Theme.gray : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(disabled ? Theme.lightGray : color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(disabled)
    }
}

struct SmallButton: View {
    let title: String
    var color: Color = Theme.violet
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(disabled ? Theme.gray : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(disabled ? Theme.lightGray : color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(disabled)
    }
}
