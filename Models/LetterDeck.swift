import Foundation

enum LetterDeck {
    // Adult-friendlier weighted distribution
    private static let weightedLetters: [String: Int] = [
        "A": 12, "E": 14, "I": 10, "O": 10, "U": 6,
        "R": 9, "S": 9, "T": 9, "L": 8, "N": 8, "H": 7, "D": 6,
        "C": 5, "M": 5, "P": 5, "B": 4, "G": 4, "F": 4, "Y": 4, "W": 4,
        "V": 3, "K": 2,
        "J": 1, "X": 1, "Q": 1, "Z": 1
    ]

    static func makeShuffledDeck() -> [LetterTile] {
        var deck: [LetterTile] = []

        for (letter, count) in weightedLetters {
            for _ in 0..<count {
                deck.append(LetterTile(letter: letter))
            }
        }

        deck.shuffle()
        return deck
    }

    static func deal(to playerCount: Int, handSize: Int) -> (hands: [[LetterTile]], drawPile: [LetterTile]) {
        var deck = makeShuffledDeck()
        var hands = Array(repeating: [LetterTile](), count: playerCount)

        guard playerCount > 0 else {
            return ([], deck)
        }

        for _ in 0..<handSize {
            for playerIndex in 0..<playerCount {
                guard !deck.isEmpty else { break }
                hands[playerIndex].append(deck.removeFirst())
            }
        }

        return (hands, deck)
    }

    static func draw(_ count: Int, from pile: inout [LetterTile]) -> [LetterTile] {
        guard count > 0, !pile.isEmpty else { return [] }

        let actualCount = min(count, pile.count)
        let drawn = Array(pile.prefix(actualCount))
        pile.removeFirst(actualCount)
        return drawn
    }

    static func refillHand(_ hand: inout [LetterTile], from pile: inout [LetterTile], targetSize: Int) {
        let needed = max(0, targetSize - hand.count)
        hand.append(contentsOf: draw(needed, from: &pile))
    }

    static func discardAndDraw(
        hand: inout [LetterTile],
        discardIndices: [Int],
        drawPile: inout [LetterTile],
        discardPile: inout [LetterTile]
    ) {
        let uniqueSorted = Array(Set(discardIndices)).sorted(by: >)

        for index in uniqueSorted {
            guard hand.indices.contains(index) else { continue }
            discardPile.append(hand.remove(at: index))
        }

        hand.append(contentsOf: draw(uniqueSorted.count, from: &drawPile))
    }

    static func rebuildDrawPileIfNeeded(drawPile: inout [LetterTile], discardPile: inout [LetterTile]) {
        guard drawPile.isEmpty, !discardPile.isEmpty else { return }
        drawPile = discardPile.shuffled()
        discardPile.removeAll()
    }
}
