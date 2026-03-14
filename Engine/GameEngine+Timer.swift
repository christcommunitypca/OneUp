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

        if isMyTurn {
            scheduleCoachEvaluation(after: 1.6)
        } else {
            clearCoachTip()
        }

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

    private func handleTurnTimeout() async {
        guard var state else { return }
        guard state.phase == .playing else { return }

        let timedOutIndex = state.currentPlayerIndex

        clearPendingTurn()
        validationMessage = nil
        roundMessage = nil
        isBlindSwapPromptVisible = false
        state.pendingBlindSwap = nil
        clearCoachTip()

        state.log.insert("\(state.players[timedOutIndex].displayName) timed out", at: 0)
        state.consecutivePasses += 1

        if state.consecutivePasses >= state.players.count {
            endRound(&state, lastPasserIndex: timedOutIndex)
            publishAndSchedule(state)
            return
        }

        advanceToNextPlayer(&state)
        publishAndSchedule(state)
    }
}
