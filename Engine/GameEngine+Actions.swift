import Foundation

@MainActor
extension GameEngine {
    func discardSelectedLetters() {
        guard var state else { return }
        guard let actorIndex = activeActorIndex(for: state) else { return }
        noteCoachRelevantAction()
        let drafted = Set(pendingTurn.insertDrafts.map(\.handIndex) + pendingTurn.swapDrafts.map(\.handIndex))
        let selected = Set(pendingTurn.selectedHandIndices)

        let discardIndices: [Int]
        if state.currentWord.isEmpty && selected.isEmpty && !pendingTurn.insertDrafts.isEmpty && pendingTurn.swapDrafts.isEmpty {
            discardIndices = pendingTurn.insertDrafts.map(\.handIndex).sorted()
        } else {
            discardIndices = Array(selected.subtracting(drafted)).sorted()
        }

        guard !discardIndices.isEmpty else {
            validationMessage = "Select cards to discard"
            return
        }

        var actorHand = state.players[actorIndex].hand

        LetterDeck.rebuildDrawPileIfNeeded(drawPile: &state.drawPile, discardPile: &state.discardPile)
        LetterDeck.discardAndDraw(
            hand: &actorHand,
            discardIndices: discardIndices,
            drawPile: &state.drawPile,
            discardPile: &state.discardPile
        )
        LetterDeck.rebuildDrawPileIfNeeded(drawPile: &state.drawPile, discardPile: &state.discardPile)

        state.players[actorIndex].hand = actorHand
        state.log.insert("\(state.players[actorIndex].displayName) discarded \(discardIndices.count) card(s)", at: 0)

        validationMessage = nil
        roundMessage = nil
        clearCoachTip()

        finishTurn(&state, actorIndex: actorIndex, reason: .discard)
        publishAndSchedule(state)
    }

    func playSelectedAction() async {
        await commitDraftTurn()
    }

    func commitDraftTurn() async {
        guard var state else { return }
        guard let actorIndex = activeActorIndex(for: state) else { return }
        guard pendingTurn.hasDraftEdits else { return }

        let originalWord = state.currentWord
        let handBefore = state.players[actorIndex].hand

        let previewWord = buildDraftPreviewWord(from: state)

        let newWordString = previewWord.map(\.letter).joined()
        let originalWordString = originalWord.map(\.letter).joined()

        guard newWordString != originalWordString else {
            validationMessage = "Turn must change the word"
            return
        }

        guard !state.playedWordsThisRound.contains(newWordString) else {
            validationMessage = "That word was already played this round"
            return
        }

        clearCoachTip()
        isValidating = true
        validationMessage = "Checking \"\(newWordString)\"..."

        let valid = await DictionaryService.isValid(newWordString, validationMode: .localThenAPI)
        isValidating = false

        guard valid else {
            validationMessage = "\"\(newWordString)\" is not a valid word"
            scheduleCoachEvaluation(after: 1.2)
            return
        }

        var newHand = handBefore

        let sortedSwaps = pendingTurn.swapDrafts.sorted { $0.order < $1.order }
        for swap in sortedSwaps {
            guard newHand.indices.contains(swap.handIndex) else { continue }
            guard originalWord.indices.contains(swap.wordIndex) else { continue }

            let removedBoardTile = originalWord[swap.wordIndex]
            newHand[swap.handIndex] = LetterTile(letter: removedBoardTile.letter, playerIndex: -1)
        }

        let insertedIndices = Set(pendingTurn.insertDrafts.map(\.handIndex))
        for index in insertedIndices.sorted(by: >) {
            guard newHand.indices.contains(index) else { continue }
            newHand.remove(at: index)
        }

        LetterDeck.rebuildDrawPileIfNeeded(drawPile: &state.drawPile, discardPile: &state.discardPile)
        LetterDeck.refillHand(&newHand, from: &state.drawPile, targetSize: state.config.handSize)

        state.players[actorIndex].hand = newHand
        state.currentWord = previewWord
        state.lastEditingPlayerIndex = actorIndex
        state.playedWordsThisRound.append(newWordString)
        state.log.insert("\(state.players[actorIndex].displayName) played → \(newWordString)", at: 0)

        validationMessage = nil
        roundMessage = nil

        finishTurn(&state, actorIndex: actorIndex, reason: .edit)
        publishAndSchedule(state)
    }

    func confirmDiscard() {
        discardSelectedLetters()
    }

    func confirmSwap() async {
        await commitDraftTurn()
    }

    func pass() {
        guard var state else { return }
        guard let actorIndex = activeActorIndex(for: state) else { return }

        validationMessage = nil
        roundMessage = nil
        clearCoachTip()
        clearPendingTurn()
        state.log.insert("\(state.players[actorIndex].displayName) passed", at: 0)

        finishTurn(&state, actorIndex: actorIndex, reason: .pass)
        publishAndSchedule(state)
    }
}
