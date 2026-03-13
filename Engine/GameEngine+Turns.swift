import Foundation

@MainActor
extension GameEngine {

    private func buildDraftPreviewWord(
        state: GameState,
        actorIndex: Int
    ) -> [LetterTile]? {
        let hand = state.players[actorIndex].hand

        for draft in pendingTurn.insertDrafts where !hand.indices.contains(draft.handIndex) {
            return nil
        }
        for draft in pendingTurn.swapDrafts where !hand.indices.contains(draft.handIndex) {
            return nil
        }

        if state.currentWord.isEmpty {
            let sortedOpeningInserts = pendingTurn.insertDrafts.sorted(by: { $0.order < $1.order })
            guard !sortedOpeningInserts.isEmpty else { return [] }

            return sortedOpeningInserts.map { draft in
                let tile = hand[draft.handIndex]
                return LetterTile(letter: tile.letter, playerIndex: actorIndex)
            }
        }

        var baseWord = state.currentWord

        for swap in pendingTurn.swapDrafts.sorted(by: { $0.order < $1.order }) {
            guard baseWord.indices.contains(swap.wordIndex) else { return nil }
            let tile = hand[swap.handIndex]
            baseWord[swap.wordIndex] = LetterTile(letter: tile.letter, playerIndex: actorIndex)
        }

        let sortedInserts = pendingTurn.insertDrafts.sorted(by: { $0.order < $1.order })
        let insertTiles = sortedInserts.map { hand[$0.handIndex] }
        let insertPositions = sortedInserts.map(\.position)

        if insertTiles.isEmpty {
            return baseWord
        }

        return buildInsertedWord(
            baseWord: baseWord,
            selectedTiles: insertTiles,
            insertionPositions: insertPositions,
            playerIndex: actorIndex
        )
    }

  
}
