import Foundation

@MainActor
extension GameEngine {

    func scheduleTurnTimerIfNeeded() {
        timerTask?.cancel()
        timerNow = Date()

        guard var state else { return }
        guard state.phase == .playing else { return }

        state.startTurnTimer(now: Date())
        self.state = state
        timerNow = Date()

        guard let expiresAt = state.turnExpiresAt else { return }

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                await MainActor.run {
                    self?.timerNow = Date()
                }

                if Date() >= expiresAt {
                    await self?.handleTurnTimeout()
                    break
                }

                try? await Task.sleep(nanoseconds: 250_000_000)
            }
        }
    }

    func remainingSeconds() -> Int? {
        guard let expires = state?.turnExpiresAt else { return nil }
        return max(0, Int(ceil(expires.timeIntervalSince(timerNow))))
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

        let timedOutCardIndex = Int.random(in: 0..<timedOutHand.count)
        let eligibleCardIndex = Int.random(in: 0..<eligibleHand.count)

        let temp = timedOutHand[timedOutCardIndex]
        timedOutHand[timedOutCardIndex] = eligibleHand[eligibleCardIndex]
        eligibleHand[eligibleCardIndex] = temp

        state.players[pending.timedOutPlayerIndex].hand = timedOutHand
        state.players[pending.eligiblePlayerIndex].hand = eligibleHand
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

        clearPendingTurn()
        validationMessage = nil
        roundMessage = nil
        isBlindSwapPromptVisible = false

        state.log.insert("\(state.players[timedOutIndex].displayName) timed out", at: 0)
        state.consecutivePasses += 1

        if state.consecutivePasses >= state.players.count {
            state.pendingBlindSwap = nil
            endRound(&state, lastPasserIndex: timedOutIndex)
            publishAndSchedule(state)
            return
        }

        advanceToNextPlayer(&state)

        let nextIndex = state.currentPlayerIndex
        if state.config.allowBlindSwapAfterTimeout && nextIndex != timedOutIndex {
            state.pendingBlindSwap = PendingBlindSwap(
                timedOutPlayerIndex: timedOutIndex,
                eligiblePlayerIndex: nextIndex,
                isAvailable: true
            )
            isBlindSwapPromptVisible = (myPlayerIndex == nextIndex)
        } else {
            state.pendingBlindSwap = nil
        }

        publishAndSchedule(state)
    }
}
