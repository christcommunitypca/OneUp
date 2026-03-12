import SwiftUI

struct HandTileView: View {
    let tile: LetterTile
    let index: Int
    let isStaged: Bool
    let stageOrder: Int?
    let isSwapSelected: Bool
    let isDiscardSelected: Bool
    let showVowelHint: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                TileCardBackground(
                    fillColor: backgroundColor,
                    borderColor: borderColor,
                    borderWidth: borderWidth
                )

                Text(tile.letter)
                    .font(.system(size: 24, weight: .black, design: .serif))
                    .foregroundColor(letterColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                if let stageOrder, isStaged {
                    TileOrderBadge(order: stageOrder)
                        .offset(x: -4, y: 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: liftAmount)
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
            .opacity(isEnabled ? 1.0 : 0.72)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.18, dampingFraction: 0.82), value: isStaged)
        .animation(.spring(response: 0.18, dampingFraction: 0.82), value: isSwapSelected)
        .animation(.spring(response: 0.18, dampingFraction: 0.82), value: isDiscardSelected)
    }

    private var backgroundColor: Color {
        if isDiscardSelected { return Color(hex: "FFF7ED") }
        if isSwapSelected { return Color(hex: "F5F3FF") }
        if isStaged { return Color(hex: "F9FAFB") }
        return .white
    }

    private var borderColor: Color {
        if isDiscardSelected { return Color(hex: "EA580C") }
        if isSwapSelected { return Color(hex: "6E4DD8") }
        if isStaged { return Color(hex: "9CA3AF") }
        return Color(hex: "D1D5DB")
    }

    private var borderWidth: CGFloat {
        if isDiscardSelected || isSwapSelected || isStaged { return 2 }
        return 1.2
    }

    private var letterColor: Color {
        if isDiscardSelected { return Color(hex: "C2410C") }
        if isSwapSelected { return Color(hex: "6E4DD8") }
        return Color(hex: "111827")
    }

    private var liftAmount: CGFloat {
        if isSwapSelected { return -8 }
        if isStaged { return -6 }
        if isDiscardSelected { return -4 }
        return 0
    }

    private var shadowColor: Color {
        if isSwapSelected { return Color(hex: "6E4DD8").opacity(0.16) }
        if isDiscardSelected { return Color(hex: "EA580C").opacity(0.14) }
        if isStaged { return Color.black.opacity(0.08) }
        return Color.black.opacity(0.05)
    }

    private var shadowRadius: CGFloat {
        if isSwapSelected || isStaged { return 6 }
        return 2
    }

    private var shadowY: CGFloat {
        if isSwapSelected || isStaged { return 3 }
        return 1
    }
}

struct WordTileView: View {
    let tile: LetterTile
    let isStaged: Bool
    let isSwapTarget: Bool
    let playerIndex: Int
    let width: CGFloat
    let height: CGFloat
    let action: (() -> Void)?

    init(
        tile: LetterTile,
        isStaged: Bool,
        isSwapTarget: Bool,
        playerIndex: Int,
        width: CGFloat = 44,
        height: CGFloat = 54,
        action: (() -> Void)?
    ) {
        self.tile = tile
        self.isStaged = isStaged
        self.isSwapTarget = isSwapTarget
        self.playerIndex = playerIndex
        self.width = width
        self.height = height
        self.action = action
    }

    var body: some View {
        Button(action: { action?() }) {
            ZStack {
                TileCardBackground(
                    fillColor: backgroundColor,
                    borderColor: borderColor,
                    borderWidth: borderWidth
                )

                Text(tile.letter)
                    .font(.system(size: min(22, max(14, width * 0.52)), weight: .black, design: .serif))
                    .minimumScaleFactor(0.45)
                    .lineLimit(1)
                    .foregroundColor(letterColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(width: width, height: height)
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .animation(.spring(response: 0.18, dampingFraction: 0.82), value: isSwapTarget)
        .animation(.spring(response: 0.18, dampingFraction: 0.82), value: isStaged)
    }

    private var backgroundColor: Color {
        if isSwapTarget { return Color(hex: "F5F3FF") }
        if isStaged { return Color(hex: "F9FAFB") }
        return .white
    }

    private var borderColor: Color {
        if isSwapTarget { return Color(hex: "6E4DD8") }
        if isStaged { return Color(hex: "9CA3AF") }
        return Color(hex: "D1D5DB")
    }

    private var borderWidth: CGFloat {
        if isSwapTarget || isStaged { return 2 }
        return 1.2
    }

    private var letterColor: Color {
        if isSwapTarget { return Color(hex: "6E4DD8") }
        return Color(hex: "111827")
    }

    private var shadowColor: Color {
        if isSwapTarget { return Color(hex: "6E4DD8").opacity(0.14) }
        if isStaged { return Color.black.opacity(0.08) }
        return Color.black.opacity(0.05)
    }

    private var shadowRadius: CGFloat {
        if isSwapTarget || isStaged { return 6 }
        return 2
    }

    private var shadowY: CGFloat {
        if isSwapTarget || isStaged { return 2 }
        return 1
    }
}

struct SlotGapView: View {
    let position: Int
    let isActive: Bool
    let isChosen: Bool
    let activeWidth: CGFloat
    let inactiveWidth: CGFloat
    let tileHeight: CGFloat
    let action: () -> Void

    init(
        position: Int,
        isActive: Bool,
        isChosen: Bool,
        activeWidth: CGFloat = 24,
        inactiveWidth: CGFloat = 8,
        tileHeight: CGFloat = 54,
        action: @escaping () -> Void
    ) {
        self.position = position
        self.isActive = isActive
        self.isChosen = isChosen
        self.activeWidth = activeWidth
        self.inactiveWidth = inactiveWidth
        self.tileHeight = tileHeight
        self.action = action
    }

    var body: some View {
        Button(action: {
            guard isActive else { return }
            action()
        }) {
            ZStack {
                if isActive {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(isChosen ? Color(hex: "EDE9FE") : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(
                                    isChosen ? Color(hex: "6E4DD8") : Color(hex: "C4B5FD"),
                                    style: StrokeStyle(lineWidth: 1.2, dash: isChosen ? [] : [3, 3])
                                )
                        )
                        .frame(width: activeWidth, height: tileHeight)
                        .contentShape(Rectangle())
                } else {
                    Color.clear
                        .frame(width: inactiveWidth, height: tileHeight)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct TileCardBackground: View {
    let fillColor: Color
    let borderColor: Color
    let borderWidth: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

private struct TileOrderBadge: View {
    let order: Int

    var body: some View {
        Text("\(order)")
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white)
            .frame(width: 18, height: 18)
            .background(
                Circle().fill(Color(hex: "6E4DD8"))
            )
    }
}
