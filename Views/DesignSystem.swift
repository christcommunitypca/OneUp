import SwiftUI

// MARK: - Theme

enum Theme {
    // One Up — premium word game for grown-ups
    // Aesthetic: classic card game meets quality editorial

    static let background = LinearGradient(
        colors: [Color(hex: "F5F1EB"), Color(hex: "FAF8F4")],
        startPoint: .top, endPoint: .bottom
    )
    static let bgPage      = Color(hex: "F5F1EB")   // warm parchment
    static let bgCard      = Color(hex: "FFFFFF")
    static let bgSurface   = Color(hex: "F0EDE6")   // slightly warmer than page
    static let bgInput     = Color(hex: "FAFAF7")

    static let navy        = Color(hex: "1B3A5C")   // deep navy — primary
    static let navyLight   = Color(hex: "EBF0F6")
    static let gold        = Color(hex: "92600A")   // warm amber — scoring, accents
    static let goldLight   = Color(hex: "FDF3E0")
    static let sage        = Color(hex: "2D6A4F")   // muted sage — valid/success
    static let sageLight   = Color(hex: "E8F4ED")
    static let crimson     = Color(hex: "9B2335")   // deep crimson — error/discard
    static let crimsonLight = Color(hex: "FAECEE")
    static let slate       = Color(hex: "4A5568")   // mid-tone for secondary text

    // Aliases used by components
    static let violet      = navy
    static let violetBright = navy
    static let violetLight = navyLight
    static let pink        = gold
    static let pinkLight   = goldLight
    static let mint        = sage
    static let mintLight   = sageLight
    static let coral       = crimson
    static let coralLight  = crimsonLight

    static let text        = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "4A5568")
    static let gray        = Color(hex: "6B7280")
    static let lightGray   = Color(hex: "F0EDE6")
    static let border      = Color(hex: "D6CEBB")   // warm tan border
    static let borderBold  = Color(hex: "B8AD9E")
    static let white       = Color.white
    static let cardShadow  = Color(hex: "3D2B1F").opacity(0.07)
    static let panelRadius: CGFloat = 8
    static let tileRadius:  CGFloat = 6
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
    Theme.navy,
    Theme.gold,
    Theme.sage,
    Theme.crimson,
    Color(hex: "5C3A7A"),   // plum
    Color(hex: "0F5C6B"),   // teal
    Color(hex: "7A4A1E"),   // sienna
    Color(hex: "1F5C3A"),   // forest
    Color(hex: "5C1A2A"),   // burgundy
    Color(hex: "2A3F5C")    // steel
]

func playerColor(_ index: Int) -> Color {
    playerPalette[index % playerPalette.count]
}

// MARK: - View Modifiers

struct PanelStyle: ViewModifier {
    var highlighted = false
    var color: Color = Theme.navy

    func body(content: Content) -> some View {
        content
            .background(Theme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: Theme.panelRadius))
            .shadow(color: highlighted ? color.opacity(0.12) : Theme.cardShadow, radius: highlighted ? 8 : 4, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.panelRadius)
                    .stroke(highlighted ? color.opacity(0.35) : Theme.border, lineWidth: 1)
            )
    }
}

extension View {
    func panelStyle(highlighted: Bool = false, color: Color = Theme.navy) -> some View {
        modifier(PanelStyle(highlighted: highlighted, color: color))
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    var color: Color = Theme.navy
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(disabled ? Theme.gray : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(disabled ? Theme.lightGray : color)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .disabled(disabled)
    }
}

// MARK: - Small Button

struct SmallButton: View {
    let title: String
    var color: Color = Theme.navy
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(disabled ? Theme.gray : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(disabled ? Theme.lightGray : color)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .disabled(disabled)
    }
}
