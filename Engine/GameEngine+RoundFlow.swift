import Foundation

@MainActor
extension GameEngine {
    enum TurnEndReason {
        case edit
        case discard
        case pass
    }

    func publishAndSchedule(_ state: GameState) {
        self.state = state

        Task {
            await syncIfMultiplayer()
        }

        switch state.phase {
        case .playing:
            scheduleTurnTimerIfNeeded()
            scheduleCPUIfNeeded()

        case .roundOver:
            scheduleNextRoundStart()

        case .gameOver:
            timerTask?.cancel()

        default:
            break
        }
    }

    func scheduleNextRoundStart() {
        roundTransitionTask?.cancel()

        roundTransitionTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard let self else { return }
            guard var state = self.state else { return }
            guard state.phase == .roundOver else { return }

            state.currentWord.removeAll()
            state.consecutivePasses = 0
            state.pendingBlindSwap = nil
            state.lastEditingPlayerIndex = nil
            state.playedWordsThisRound = []
            state.phase = .playing
            state.startTurnTimer()

            self.roundMessage = nil
            self.state = state

            await self.syncIfMultiplayer()
            self.scheduleTurnTimerIfNeeded()
            self.scheduleCPUIfNeeded()
        }
    }

    func finishTurn(
        _ state: inout GameState,
        actorIndex: Int,
        reason: TurnEndReason
    ) {
        clearPendingTurn()
        state.pendingBlindSwap = nil

        switch reason {
        case .edit:
            state.consecutivePasses = 0
            advanceToNextPlayer(&state)

        case .discard, .pass:
            state.consecutivePasses += 1

            if state.consecutivePasses >= state.players.count {
                endRound(&state, lastPasserIndex: actorIndex)
            } else {
                advanceToNextPlayer(&state)
            }
        }
    }

    func endRound(_ state: inout GameState, lastPasserIndex: Int) {
        timerTask?.cancel()

        guard !state.players.isEmpty else { return }

        if state.currentWord.isEmpty {
            let nextStarter = (lastPasserIndex + 1) % state.players.count

            for index in state.players.indices {
                LetterDeck.rebuildDrawPileIfNeeded(drawPile: &state.drawPile, discardPile: &state.discardPile)
                let drawn = LetterDeck.draw(1, from: &state.drawPile)
                state.players[index].hand.append(contentsOf: drawn)
            }

            state.pendingBlindSwap = nil
            state.lastEditingPlayerIndex = nil
            state.playedWordsThisRound = []
            state.currentPlayerIndex = nextStarter
            state.phase = .roundOver
            state.clearTurnTimer()
            roundMessage = "Round over. No word built. Everyone drew 1."
            return
        }

        let scorerIndex: Int
        if let lastEditor = state.lastEditingPlayerIndex,
           state.players.indices.contains(lastEditor) {
            scorerIndex = lastEditor
        } else {
            scorerIndex = ((lastPasserIndex - 1) + state.players.count) % state.players.count
        }

        let points = state.wordPoints
        let finalWord = state.wordString
        let scorerName = state.players[scorerIndex].displayName

        state.players[scorerIndex].score += points
        state.log.insert("\(scorerName) scored \(points) for \"\(finalWord)\"", at: 0)

        if state.players[scorerIndex].score >= state.config.winScore {
            state.phase = .gameOver
            state.winnerName = scorerName
            state.clearTurnTimer()
            state.pendingBlindSwap = nil
            roundMessage = "Game over. \(scorerName) wins."
            return
        }

        state.pendingBlindSwap = nil
        state.currentPlayerIndex = scorerIndex
        state.phase = .roundOver
        state.clearTurnTimer()
        roundMessage = "Round over. \(scorerName) scores \(points). Total: \(state.players[scorerIndex].score)"
    }
}
