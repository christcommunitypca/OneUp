import Foundation

struct CPUPlayer {

    /// Find the best move for the CPU given its hand and the current word.
    /// Returns nil if it should pass.
    static func findMove(hand: [LetterTile], currentWord: [LetterTile]) -> CPUMove? {
        let curStr = currentWord.map(\.letter).joined()

        // Try inserting one letter at every possible position
        for pos in 0...curStr.count {
            for card in hand {
                let test = String(curStr.prefix(pos)) + card.letter + String(curStr.dropFirst(pos))
                if LocalWordList.contains(test) {
                    return .insert(card: card, position: pos)
                }
            }
        }

        // If word is empty, try building 2-5 letter words from permutations
        if curStr.isEmpty {
            let maxLen = min(5, hand.count)
            for len in 2...maxLen {
                for perm in permutations(of: hand, length: len) {
                    let word = perm.map(\.letter).joined()
                    if LocalWordList.contains(word) {
                        return .newWord(cards: perm)
                    }
                }
            }
        }

        return nil  // must pass
    }

    // MARK: - Permutation helper

    private static func permutations(of tiles: [LetterTile], length: Int) -> [[LetterTile]] {
        guard length > 0, !tiles.isEmpty else { return [[]] }
        if length == 1 { return tiles.map { [$0] } }
        var result: [[LetterTile]] = []
        for (i, tile) in tiles.enumerated() {
            var rest = tiles
            rest.remove(at: i)
            for perm in permutations(of: rest, length: length - 1) {
                result.append([tile] + perm)
            }
        }
        return result
    }
}

enum CPUMove {
    case insert(card: LetterTile, position: Int)
    case newWord(cards: [LetterTile])

    var tilesPlayed: [LetterTile] {
        switch self {
        case .insert(let card, _): return [card]
        case .newWord(let cards): return cards
        }
    }
}
