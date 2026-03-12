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
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(letterColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                if let stageOrder, isStaged {
                    TileOrderBadge(order: stageOrder)
                        .offset(x: -3, y: 3)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: liftAmount)
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
            .opacity(isEnabled ? 1.0 : 0.65)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.18, dampingFraction: 0.82), value: isStaged)
        .animation(.spring(response: 0.18, dampingFraction: 0.82), value: isSwapSelected)
        .animation(.spring(response: 0.18, dampingFraction: 0.82), value: isDiscardSelected)
    }

    private var backgroundColor: Color {
        if isDiscardSelected { return Theme.crimsonLight }
        if isSwapSelected    { return Theme.goldLight }
        if isStaged          { return Theme.navyLight }
        return .white
    }

    private var borderColor: Color {
        if isDiscardSelected { return Theme.crimson }
        if isSwapSelected    { return Theme.gold }
        if isStaged          { return Theme.navy }
        return Theme.borderBold
    }

    private var borderWidth: CGFloat {
        if isDiscardSelected || isSwapSelected || isStaged { return 1.5 }
        return 1
    }

    private var letterColor: Color {
        if isDiscardSelected { return Theme.crimson }
        if isSwapSelected    { return Theme.gold }
        if isStaged          { return Theme.navy }
        return Theme.text
    }

    private var liftAmount: CGFloat {
        if isSwapSelected    { return -7 }
        if isStaged          { return -5 }
        if isDiscardSelected { return -3 }
        return 0
    }

    private var shadowColor: Color {
        if isSwapSelected    { return Theme.gold.opacity(0.18) }
        if isDiscardSelected { return Theme.crimson.opacity(0.15) }
        if isStaged          { return Theme.navy.opacity(0.18) }
        return Theme.cardShadow
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
                    .font(.system(size: min(20, max(13, width * 0.50)), weight: .bold, design: .serif))
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
        if isSwapTarget { return Theme.navyLight }
        if isStaged     { return Theme.sageLight }
        return .white
    }

    private var borderColor: Color {
        if isSwapTarget { return Theme.navy }
        if isStaged     { return Theme.sage }
        return Theme.borderBold
    }

    private var borderWidth: CGFloat {
        if isSwapTarget || isStaged { return 1.5 }
        return 1
    }

    private var letterColor: Color {
        if isSwapTarget { return Theme.navy }
        if isStaged     { return Theme.sage }
        return Theme.text
    }

    private var shadowColor: Color {
        if isSwapTarget { return Theme.navy.opacity(0.12) }
        if isStaged     { return Theme.sage.opacity(0.12) }
        return Theme.cardShadow
    }

    private var shadowRadius: CGFloat { isSwapTarget || isStaged ? 5 : 2 }
    private var shadowY: CGFloat { isSwapTarget || isStaged ? 2 : 1 }
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
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(isChosen ? Theme.navyLight : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(
                                    isChosen ? Theme.navy : Theme.navy.opacity(0.35),
                                    style: StrokeStyle(lineWidth: 1.2, dash: isChosen ? [] : [4, 3])
                                )
                        )
                        .frame(width: activeWidth, height: tileHeight)
                        .contentShape(Rectangle())
                } else {
                    Color.clear.frame(width: inactiveWidth, height: tileHeight)
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
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

private struct TileOrderBadge: View {
    let order: Int

    var body: some View {
        Text("\(order)")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 16, height: 16)
            .background(Circle().fill(Theme.navy))
    }
}
