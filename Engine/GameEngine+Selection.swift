//
//  GameEngine+Selection.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

import Foundation

@MainActor
extension GameEngine {
    func toggleHandSelection(at handIndex: Int) {
        guard isMyTurn, let state, let mine = myPlayerIndex else { return }
        guard state.players[mine].hand.indices.contains(handIndex) else { return }

        roundMessage = nil
        validationMessage = nil

        if state.currentWord.isEmpty {
            if let existing = pendingTurn.insertDrafts.firstIndex(where: { $0.handIndex == handIndex }) {
                pendingTurn.insertDrafts.remove(at: existing)
                pendingTurn.action = .none
                refreshPendingTurnMirrors()
                updateLivePreview()
                return
            }

            pendingTurn.insertDrafts.append(
                DraftInsert(handIndex: handIndex, position: 0, order: nextDraftOrder())
            )
            pendingTurn.action = .none
            pendingTurn.activeHandIndex = nil
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        if let existing = pendingTurn.insertDrafts.firstIndex(where: { $0.handIndex == handIndex }) {
            pendingTurn.insertDrafts.remove(at: existing)
            pendingTurn.action = .none
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        if let existing = pendingTurn.swapDrafts.firstIndex(where: { $0.handIndex == handIndex }) {
            pendingTurn.swapDrafts.remove(at: existing)
            pendingTurn.action = .none
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        if pendingTurn.selectedHandIndices.contains(handIndex) {
            pendingTurn.selectedHandIndices.removeAll { $0 == handIndex }
            if pendingTurn.activeHandIndex == handIndex {
                pendingTurn.activeHandIndex = nil
            }
            pendingTurn.action = .none
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        pendingTurn.selectedHandIndices.append(handIndex)
        pendingTurn.selectedHandIndices = Array(Set(pendingTurn.selectedHandIndices)).sorted()

        if pendingTurn.selectedHandCount == 1 {
            pendingTurn.activeHandIndex = handIndex
        } else {
            pendingTurn.activeHandIndex = nil
        }

        pendingTurn.action = .none
        refreshPendingTurnMirrors()
        updateLivePreview()
    }

    func chooseInsertPosition(_ position: Int) {
        guard isMyTurn, let state else { return }
        guard pendingTurn.hasSingleSelection, let handIndex = pendingTurn.selectedHandIndices.first else { return }

        roundMessage = nil
        validationMessage = nil

        if state.currentWord.isEmpty {
            pendingTurn.insertDrafts.append(
                DraftInsert(handIndex: handIndex, position: 0, order: nextDraftOrder())
            )
            pendingTurn.selectedHandIndices.removeAll { $0 == handIndex }
            pendingTurn.activeHandIndex = nil
            pendingTurn.action = .none
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        guard let basePosition = baseWordGapPositionForVisibleGap(
            position,
            baseWordCount: state.currentWord.count
        ) else {
            validationMessage = "Choose a gap between board letters"
            return
        }

        pendingTurn.insertDrafts.append(
            DraftInsert(handIndex: handIndex, position: basePosition, order: nextDraftOrder())
        )
        pendingTurn.selectedHandIndices.removeAll { $0 == handIndex }
        pendingTurn.activeHandIndex = nil
        pendingTurn.action = .none
        refreshPendingTurnMirrors()
        updateLivePreview()
    }

    func chooseSwapMode() {
    }

    func chooseDiscardMode() {
    }

    func chooseWordIndexForSwap(_ wordIndex: Int) {
        guard isMyTurn else { return }
        guard let state else { return }
        guard !state.currentWord.isEmpty else { return }
        guard pendingTurn.hasSingleSelection, let handIndex = pendingTurn.selectedHandIndices.first else { return }
        guard pendingTurn.canAddAnotherSwap else {
            validationMessage = "You can swap at most 2 letters"
            return
        }

        roundMessage = nil
        validationMessage = nil

        guard let baseWordIndex = baseWordIndexForVisibleSwapIndex(
            wordIndex,
            baseWordCount: state.currentWord.count
        ) else {
            return
        }

        pendingTurn.swapDrafts.removeAll { $0.wordIndex == baseWordIndex }

        pendingTurn.swapDrafts.append(
            DraftSwap(handIndex: handIndex, wordIndex: baseWordIndex, order: nextDraftOrder())
        )

        pendingTurn.selectedHandIndices.removeAll { $0 == handIndex }
        pendingTurn.activeHandIndex = nil
        pendingTurn.action = .none

        refreshPendingTurnMirrors()
        updateLivePreview()
    }

    func clearPendingTurn() {
        pendingTurn = .init()
        livePreviewWord = []
        livePreviewIsValid = nil
    }
}
