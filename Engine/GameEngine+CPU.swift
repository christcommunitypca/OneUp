import Foundation

@MainActor
extension GameEngine {

    func scheduleCPUIfNeeded() {
        cpuTask?.cancel()

        guard let state else { return }
        guard state.phase == .playing else { return }
        guard state.currentPlayer.isComputer else { return }

        cpuTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(Config.cpuThinkTimeSeconds * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await self?.executeCPUTurn()
        }
    }

    private func executeCPUTurn() async {
        guard let state else { return }
        guard state.phase == .playing else { return }
        guard state.currentPlayer.isComputer else { return }

        clearPendingTurn()

        let currentIndex = state.currentPlayerIndex
        let hand = state.players[currentIndex].hand
        let currentWord = state.currentWord

        if !currentWord.isEmpty {
            if await tryCPUInsert(currentIndex: currentIndex, hand: hand, currentWord: currentWord) {
                return
            }

            pass()
            return
        }

        if await tryCPUOpeningPlay(currentIndex: currentIndex, hand: hand) {
            return
        }

        pass()
    }

    private func tryCPUInsert(
        currentIndex: Int,
        hand: [LetterTile],
        currentWord: [LetterTile]
    ) async -> Bool {
        let currentWordString = currentWord.map(\.letter).joined()

        for (handIndex, tile) in hand.enumerated() {
            for pos in 0...currentWord.count {
                let candidate = buildInsertedWord(
                    baseWord: currentWord,
                    selectedTiles: [tile],
                    insertionPositions: [pos],
                    playerIndex: currentIndex
                )

                let word = candidate.map(\.letter).joined()
                guard word != currentWordString else { continue }

                if await DictionaryService.isValid(word) {
                    clearPendingTurn()
                    pendingTurn.action = .insert
                    pendingTurn.insertDrafts = [
                        DraftInsert(handIndex: handIndex, position: pos, order: 1)
                    ]
                    refreshPendingTurnMirrors()
                    updateLivePreview()

                    await playSelectedAction()
                    return true
                }
            }
        }

        return false
    }

    private func tryCPUOpeningPlay(
        currentIndex: Int,
        hand: [LetterTile]
    ) async -> Bool {
        let maxLen = min(5, hand.count)
        guard maxLen >= 2 else { return false }

        for length in 2...maxLen {
            let combos = combinations(of: Array(hand.enumerated()), taking: length)
            for combo in combos {
                let letters = combo.map(\.element.letter)
                let perms = permutations(of: letters)

                for perm in perms {
                    let word = perm.joined()
                    if await DictionaryService.isValid(word) {
                        var available = combo.map { ($0.offset, $0.element.letter) }
                        var chosenIndices: [Int] = []

                        for letter in perm {
                            if let idx = available.firstIndex(where: { $0.1 == letter }) {
                                chosenIndices.append(available[idx].0)
                                available.remove(at: idx)
                            }
                        }

                        clearPendingTurn()
                        pendingTurn.action = .insert
                        pendingTurn.insertDrafts = chosenIndices.enumerated().map { offset, handIndex in
                            DraftInsert(handIndex: handIndex, position: 0, order: offset + 1)
                        }
                        refreshPendingTurnMirrors()
                        updateLivePreview()

                        await playSelectedAction()
                        return true
                    }
                }
            }
        }

        return false
    }
}
