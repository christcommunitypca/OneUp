import Foundation

@MainActor
extension GameEngine {

    func scheduleTurnTimerIfNeeded() {
        timerTask?.cancel()

        guard var state else { return }
        guard state.phase == .playing else { return }

        state.startTurnTimer()
        self.state = state

        guard let expiresAt = state.turnExpiresAt else { return }

        let delay = expiresAt.timeIntervalSinceNow
        guard delay > 0 else {
            Task { await handleTurnTimeout() }
            return
        }

        timerTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await self?.handleTurnTimeout()
        }
    }

    func remainingSeconds() -> Int? {
        guard let expires = state?.turnExpiresAt else { return nil }
        return max(0, Int(ceil(expires.timeIntervalSinceNow)))
    }

    func declineBlindSwap() {
        guard var state else { return }
        state.pendingBlindSwap = nil
        self.state = state
        isBlindSwapPromptVisible = false
    }

    func acceptBlindSwap() {
        guard var state else { return }
        guard let pending = state.pendingBlindSwap, pending.isAvailable else { return }
        guard state.players.indices.contains(pending.timedOutPlayerIndex),
              state.players.indices.contains(pending.eligiblePlayerIndex) else { return }

        var timedOutHand = state.players[pending.timedOutPlayerIndex].hand
        var eligibleHand = state.players[pending.eligiblePlayerIndex].hand

        guard !timedOutHand.isEmpty, !eligibleHand.isEmpty else {
            state.pendingBlindSwap = nil
            self.state = state
            isBlindSwapPromptVisible = false
            return
        }

        let timedOutIndex = Int.random(in: 0..<timedOutHand.count)
        let eligibleIndex = Int.random(in: 0..<eligibleHand.count)

        let temp = timedOutHand[timedOutIndex]
        timedOutHand[timedOutIndex] = eligibleHand[eligibleIndex]
        eligibleHand[eligibleIndex] = temp

        state.players[pending.timedOutPlayerIndex].hand = timedOutHand
        state.players[pending.eligiblePlayerIndex].hand = eligibleHand
        state.log.insert("\(state.players[pending.eligiblePlayerIndex].displayName) made a blind swap after timeout", at: 0)
        state.pendingBlindSwap = nil

        self.state = state
        isBlindSwapPromptVisible = false

        Task {
            await syncIfMultiplayer()
        }
    }

    private func handleTurnTimeout() async {
        guard var state else { return }
        guard state.phase == .playing else { return }

        let timedOutIndex = state.currentPlayerIndex
        state.log.insert("\(state.currentPlayer.displayName) ran out of time", at: 0)

        let nextIndex = state.nextPlayerIndex

        if state.config.allowBlindSwapAfterTimeout && nextIndex != timedOutIndex {
            state.pendingBlindSwap = PendingBlindSwap(
                timedOutPlayerIndex: timedOutIndex,
                eligiblePlayerIndex: nextIndex,
                isAvailable: true
            )
            isBlindSwapPromptVisible = (myPlayerIndex == nextIndex)
        } else {
            state.pendingBlindSwap = nil
            isBlindSwapPromptVisible = false
        }

        clearPendingTurn()
        validationMessage = nil
        roundMessage = nil

        finishTurn(&state, actorIndex: timedOutIndex, reason: .pass)
        publishAndSchedule(state)
    }
}
