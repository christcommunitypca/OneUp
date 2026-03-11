//
//  WordBoardSurfaceView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

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
        VStack(alignment: .leading, spacing: 8) {
            if isOpeningRound {
                openingBoard
            } else {
                interactiveBoard
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(hex: "FAFAF9"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
        )
    }

    private var openingBoard: some View {
        VStack {
            if !livePreviewWord.isEmpty {
                tileRow(livePreviewWord)
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(hex: "D1D5DB"), style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
                    .frame(height: 82)
                    .overlay(
                        VStack(spacing: 4) {
                            Text("Your opening word will appear here")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "6E4DD8"))
                            Text("Tap hand cards to build it.")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                    )
            }
        }
    }

    private var interactiveBoard: some View {
        let displayWord = !livePreviewWord.isEmpty ? livePreviewWord : currentWord

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                gapView(position: 0)

                ForEach(Array(displayWord.enumerated()), id: \.element.id) { index, tile in
                    WordTileView(
                        tile: tile,
                        isStaged: isPreviewInsertedTile(index: index, tile: tile),
                        isSwapTarget: pendingTurn.swapDrafts.contains(where: { $0.wordIndex == index }),
                        playerIndex: max(0, tile.playerIndex),
                        action: swapAction(for: index)
                    )

                    gapView(position: index + 1)
                }
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private func gapView(position: Int) -> some View {
        let active = isMyTurn &&
            pendingTurn.action != .discard &&
            pendingTurn.activeHandIndex != nil &&
            pendingTurn.action != .swap

        let chosen = pendingTurn.insertDrafts.contains(where: { $0.position == position })

        SlotGapView(
            position: position,
            isActive: active,
            isChosen: chosen
        ) {
            onChooseInsertPosition(position)
        }
    }

    private func swapAction(for index: Int) -> (() -> Void)? {
        guard isMyTurn else { return nil }
        guard pendingTurn.action == .swap else { return nil }
        guard pendingTurn.activeHandIndex != nil else { return nil }

        return {
            onChooseSwapIndex(index)
        }
    }

    private func tileRow(_ tiles: [LetterTile]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(tiles.enumerated()), id: \.element.id) { index, tile in
                    WordTileView(
                        tile: tile,
                        isStaged: isPreviewInsertedTile(index: index, tile: tile),
                        isSwapTarget: pendingTurn.swapDrafts.contains(where: { $0.wordIndex == index }),
                        playerIndex: max(0, tile.playerIndex),
                        action: nil
                    )
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func isPreviewInsertedTile(index: Int, tile: LetterTile) -> Bool {
        guard pendingTurn.hasDraftEdits else { return false }
        if index >= currentWord.count { return true }
        if currentWord[index].id != tile.id { return true }
        return false
    }
}
