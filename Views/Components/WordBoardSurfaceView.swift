import SwiftUI

struct WordBoardSurfaceView: View {
    let isOpeningRound: Bool
    let livePreviewWord: [LetterTile]
    let currentWord: [LetterTile]
    let isMyTurn: Bool
    let pendingTurn: PendingTurn
    let onChooseInsertPosition: (Int) -> Void
    let onChooseSwapIndex: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isOpeningRound { openingBoard } else { interactiveBoard }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.bgSurface))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Theme.border, lineWidth: 1))
    }

    private var openingBoard: some View {
        GeometryReader { proxy in
            let metrics = boardMetrics(containerWidth: proxy.size.width, letterCount: max(1, livePreviewWord.count))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    SlotGapView(position: 0, isActive: false, isChosen: false,
                                activeWidth: metrics.gapWidth, inactiveWidth: metrics.gapWidth, tileHeight: metrics.tileHeight) { }
                    ForEach(Array(livePreviewWord.enumerated()), id: \.element.id) { _, tile in
                        WordTileView(tile: tile, isStaged: true, isSwapTarget: false,
                                     playerIndex: max(0, tile.playerIndex),
                                     width: metrics.tileWidth, height: metrics.tileHeight, action: nil)
                        SlotGapView(position: 0, isActive: false, isChosen: false,
                                    activeWidth: metrics.gapWidth, inactiveWidth: metrics.gapWidth, tileHeight: metrics.tileHeight) { }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .frame(height: 80)
        .overlay(alignment: .topLeading) {
            if livePreviewWord.isEmpty {
                Text("Tap letters in the order you want them placed.")
                    .font(.system(size: 11, weight: .regular)).foregroundColor(Theme.gray)
                    .padding(.top, 4).padding(.leading, 4)
            }
        }
    }

    private var interactiveBoard: some View {
        let displayWord = !livePreviewWord.isEmpty ? livePreviewWord : currentWord
        return GeometryReader { proxy in
            let metrics = boardMetrics(containerWidth: proxy.size.width, letterCount: max(1, displayWord.count))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    gapView(position: 0, gapWidth: metrics.gapWidth, tileHeight: metrics.tileHeight)
                    ForEach(Array(displayWord.enumerated()), id: \.element.id) { index, tile in
                        WordTileView(
                            tile: tile,
                            isStaged: isPreviewInsertedTile(index: index, tile: tile),
                            isSwapTarget: pendingTurn.swapDrafts.contains(where: { $0.wordIndex == index }),
                            playerIndex: max(0, tile.playerIndex),
                            width: metrics.tileWidth, height: metrics.tileHeight,
                            action: boardTapAction(for: index)
                        )
                        gapView(position: index + 1, gapWidth: metrics.gapWidth, tileHeight: metrics.tileHeight)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .frame(height: 80)
    }

    @ViewBuilder
    private func gapView(position: Int, gapWidth: CGFloat, tileHeight: CGFloat) -> some View {
        let active = isMyTurn && pendingTurn.hasSingleSelection
        let chosen = pendingTurn.insertDrafts.contains(where: { $0.position == position })
        SlotGapView(position: position, isActive: active, isChosen: chosen,
                    activeWidth: gapWidth, inactiveWidth: max(6, gapWidth * 0.42), tileHeight: tileHeight) {
            guard active else { return }
            onChooseInsertPosition(position)
        }
    }

    private func boardTapAction(for index: Int) -> (() -> Void)? {
        guard isMyTurn, pendingTurn.hasSingleSelection else { return nil }
        return { onChooseSwapIndex(index) }
    }

    private func isPreviewInsertedTile(index: Int, tile: LetterTile) -> Bool {
        guard pendingTurn.hasDraftEdits else { return false }
        if index >= currentWord.count { return true }
        if currentWord[index].id != tile.id { return true }
        return false
    }

    private func boardMetrics(containerWidth: CGFloat, letterCount: Int) -> (tileWidth: CGFloat, gapWidth: CGFloat, tileHeight: CGFloat) {
        let baseTile: CGFloat = 44, baseGap: CGFloat = 22, tileH: CGFloat = 54
        let desired = CGFloat(letterCount) * baseTile + CGFloat(letterCount + 1) * baseGap
        let scale = min(1, max(140, containerWidth - 4) / desired)
        return (max(24, baseTile * scale), max(10, baseGap * scale), tileH)
    }
}
