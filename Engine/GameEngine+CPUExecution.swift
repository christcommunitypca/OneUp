//
//  GameEngine+CPUExecution.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

import Foundation

@MainActor
extension GameEngine {
    func executeCPUTurn() async {
        guard let state else { return }
        guard state.phase == .playing else { return }
        guard state.currentPlayer.isComputer else { return }

        clearPendingTurn()

        let currentIndex = state.currentPlayerIndex
        let difficulty = state.currentPlayer.cpuDifficulty ?? state.config.defaultCPUDifficulty
        let profile = cpuProfile(for: difficulty)

        if let move = await findBestCPUMove(state: state, actorIndex: currentIndex, profile: profile) {
            await applyCPUMove(move)
            return
        }

        if profile.usesDiscardWhenStuck,
           executeCPUDiscard(actorIndex: currentIndex, discardCount: profile.discardCount) {
            return
        }

        pass()
    }

    func applyCPUMove(_ move: CPUCandidate) async {
        clearPendingTurn()
        pendingTurn.insertDrafts = move.inserts
        pendingTurn.swapDrafts = move.swaps
        pendingTurn.action = move.swaps.isEmpty ? .insert : .swap
        refreshPendingTurnMirrors()
        updateLivePreview()
        await playSelectedAction()
    }

    @discardableResult
    func executeCPUDiscard(actorIndex: Int, discardCount: Int) -> Bool {
        guard let state else { return false }
        let hand = state.players[actorIndex].hand
        guard hand.count >= 2, discardCount > 0 else { return false }

        let ranked = hand.enumerated().sorted { lhs, rhs in
            let leftScore = discardPriority(for: lhs.element.letter)
            let rightScore = discardPriority(for: rhs.element.letter)
            if leftScore == rightScore {
                return lhs.offset < rhs.offset
            }
            return leftScore > rightScore
        }

        let indices = ranked.prefix(discardCount).map(\.offset).sorted()
        guard !indices.isEmpty else { return false }

        clearPendingTurn()
        pendingTurn.selectedHandIndices = indices
        refreshPendingTurnMirrors()
        discardSelectedLetters()
        return true
    }
}
