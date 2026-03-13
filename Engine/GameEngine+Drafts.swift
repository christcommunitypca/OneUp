//
//  GameEngine+Drafts.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

import Foundation

@MainActor
extension GameEngine {
    func nextDraftOrder() -> Int {
        let insertMax = pendingTurn.insertDrafts.map(\.order).max() ?? 0
        let swapMax = pendingTurn.swapDrafts.map(\.order).max() ?? 0
        return max(insertMax, swapMax) + 1
    }

    func refreshPendingTurnMirrors() {
        let draftedInsertHandIndices = pendingTurn.insertDrafts.map(\.handIndex)
        let draftedSwapHandIndices = pendingTurn.swapDrafts.map(\.handIndex)
        let draftedHandIndices = Set(draftedInsertHandIndices + draftedSwapHandIndices)

        pendingTurn.selectedHandIndices = pendingTurn.selectedHandIndices
            .filter { !draftedHandIndices.contains($0) }

        if let active = pendingTurn.activeHandIndex,
           draftedHandIndices.contains(active) {
            pendingTurn.activeHandIndex = nil
        }

        if pendingTurn.selectedHandCount != 1 {
            pendingTurn.activeHandIndex = nil
        } else if let selected = pendingTurn.selectedHandIndices.first {
            pendingTurn.activeHandIndex = selected
        }
    }

    func buildDraftPreviewWord(from state: GameState) -> [LetterTile] {
        var word = state.currentWord

        let orderedSwaps = pendingTurn.swapDrafts.sorted { $0.order < $1.order }
        for swap in orderedSwaps {
            guard word.indices.contains(swap.wordIndex) else { continue }
            guard state.players[state.currentPlayerIndex].hand.indices.contains(swap.handIndex) else { continue }
            word[swap.wordIndex] = state.players[state.currentPlayerIndex].hand[swap.handIndex]
        }

        let orderedInserts = pendingTurn.insertDrafts.sorted { lhs, rhs in
            if lhs.position == rhs.position { return lhs.order < rhs.order }
            return lhs.position < rhs.position
        }

        var offset = 0
        for insert in orderedInserts {
            guard state.players[state.currentPlayerIndex].hand.indices.contains(insert.handIndex) else { continue }
            let tile = state.players[state.currentPlayerIndex].hand[insert.handIndex]
            let insertionIndex = max(0, min(word.count, insert.position + offset))
            word.insert(tile, at: insertionIndex)
            offset += 1
        }

        return word
    }

    func baseWordGapPositionForVisibleGap(_ visibleGap: Int, baseWordCount: Int) -> Int? {
        guard visibleGap >= 0 else { return nil }

        let orderedInsertPositions = pendingTurn.insertDrafts
            .sorted { lhs, rhs in
                if lhs.position == rhs.position { return lhs.order < rhs.order }
                return lhs.position < rhs.position
            }
            .map(\.position)

        var previewGap = 0
        var baseGap = 0
        var insertIndex = 0

        while baseGap <= baseWordCount {
            while insertIndex < orderedInsertPositions.count,
                  orderedInsertPositions[insertIndex] == baseGap {
                if previewGap == visibleGap { return baseGap }
                previewGap += 1
                insertIndex += 1
            }

            if previewGap == visibleGap { return baseGap }
            previewGap += 1
            baseGap += 1
        }

        return nil
    }

    func baseWordIndexForVisibleSwapIndex(_ visibleIndex: Int, baseWordCount: Int) -> Int? {
        guard visibleIndex >= 0 else { return nil }

        let insertsBeforeOrAt: (Int) -> Int = { target in
            self.pendingTurn.insertDrafts.reduce(into: 0) { count, draft in
                if draft.position <= target { count += 1 }
            }
        }

        for baseIndex in 0..<baseWordCount {
            let visibleBaseIndex = baseIndex + insertsBeforeOrAt(baseIndex)
            if visibleBaseIndex == visibleIndex {
                return baseIndex
            }
        }

        return nil
    }
}
