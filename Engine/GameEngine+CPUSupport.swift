import Foundation

@MainActor
extension GameEngine {
    enum CPUSelectionStyle {
        case weakestLegal
        case strongestLegal
        case strongestStrategic
    }

    struct CPUProfile {
        let openingMaxLength: Int
        let allowSingleInsert: Bool
        let allowDoubleInsert: Bool
        let allowSingleSwap: Bool
        let usesDiscardWhenStuck: Bool
        let discardCount: Int
        let selectionStyle: CPUSelectionStyle
        let handQualityWeight: Int
    }

    struct CPUCandidate {
        let word: String
        let inserts: [DraftInsert]
        let swaps: [DraftSwap]
        let score: Int
    }

    func cpuProfile(for difficulty: CPUDifficulty) -> CPUProfile {
        switch difficulty {
        case .rookie:
            return CPUProfile(
                openingMaxLength: 3,
                allowSingleInsert: true,
                allowDoubleInsert: false,
                allowSingleSwap: false,
                usesDiscardWhenStuck: false,
                discardCount: 0,
                selectionStyle: .weakestLegal,
                handQualityWeight: 0
            )

        case .pro:
            return CPUProfile(
                openingMaxLength: 5,
                allowSingleInsert: true,
                allowDoubleInsert: false,
                allowSingleSwap: false,
                usesDiscardWhenStuck: false,
                discardCount: 0,
                selectionStyle: .strongestLegal,
                handQualityWeight: 1
            )

        case .elite:
            return CPUProfile(
                openingMaxLength: 6,
                allowSingleInsert: true,
                allowDoubleInsert: false,
                allowSingleSwap: true,
                usesDiscardWhenStuck: true,
                discardCount: 1,
                selectionStyle: .strongestLegal,
                handQualityWeight: 2
            )

        case .expert:
            return CPUProfile(
                openingMaxLength: 7,
                allowSingleInsert: true,
                allowDoubleInsert: false,
                allowSingleSwap: true,
                usesDiscardWhenStuck: true,
                discardCount: 1,
                selectionStyle: .strongestStrategic,
                handQualityWeight: 3
            )

        case .master:
            return CPUProfile(
                openingMaxLength: 7,
                allowSingleInsert: true,
                allowDoubleInsert: true,
                allowSingleSwap: true,
                usesDiscardWhenStuck: true,
                discardCount: 2,
                selectionStyle: .strongestStrategic,
                handQualityWeight: 4
            )
        }
    }

    func chooseCandidate(from candidates: [CPUCandidate], style: CPUSelectionStyle) -> CPUCandidate? {
        guard !candidates.isEmpty else { return nil }

        let sorted = candidates.sorted {
            if $0.score == $1.score {
                if $0.word.count == $1.word.count {
                    return $0.word < $1.word
                }
                return $0.word.count < $1.word.count
            }
            return $0.score < $1.score
        }

        switch style {
        case .weakestLegal:
            let weakPool = Array(sorted.prefix(min(3, sorted.count)))
            return weakPool.randomElement() ?? sorted.first

        case .strongestLegal, .strongestStrategic:
            return sorted.last
        }
    }

    func scoreCandidate(
        word: String,
        hand: [LetterTile],
        currentWord: [LetterTile],
        inserts: [DraftInsert],
        swaps: [DraftSwap],
        handQualityWeight: Int
    ) -> Int {
        let baseScore = points(forWordLength: word.count)
        let insertBonus = inserts.count * 3
        let swapBonus = swaps.count * 2
        let leftovers = simulatedHandAfterMove(
            hand: hand,
            currentWord: currentWord,
            inserts: inserts,
            swaps: swaps
        )
        let handQuality = evaluateHand(leftovers)
        return baseScore + insertBonus + swapBonus + (handQuality * handQualityWeight)
    }

    func points(forWordLength count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (0..<count).reduce(0) { partial, index in
            partial + (index < 4 ? 1 : 2)
        }
    }

    func simulatedHandAfterMove(
        hand: [LetterTile],
        currentWord: [LetterTile],
        inserts: [DraftInsert],
        swaps: [DraftSwap]
    ) -> [String] {
        let insertedIndices = Set(inserts.map(\.handIndex))
        var leftovers: [String] = hand.enumerated().compactMap { index, tile in
            insertedIndices.contains(index) ? nil : tile.letter
        }

        for swap in swaps {
            guard currentWord.indices.contains(swap.wordIndex), hand.indices.contains(swap.handIndex) else { continue }
            if let existingIndex = leftovers.firstIndex(of: hand[swap.handIndex].letter) {
                leftovers.remove(at: existingIndex)
            }
            leftovers.append(currentWord[swap.wordIndex].letter)
        }

        return leftovers
    }

    func evaluateHand(_ letters: [String]) -> Int {
        guard !letters.isEmpty else { return 6 }

        let vowels = letters.filter { "AEIOU".contains($0) }.count
        let consonants = letters.count - vowels
        let balance = max(0, 4 - abs(vowels - consonants))

        var seen: [String: Int] = [:]
        for letter in letters {
            seen[letter, default: 0] += 1
        }

        let duplicatePenalty = seen.values.reduce(0) { partial, value in
            partial + max(0, value - 1)
        }

        let awkwardPenalty = letters.reduce(0) { partial, letter in
            partial + awkwardLetterPenalty(letter)
        }

        let flexibilityBonus = letters.reduce(0) { partial, letter in
            partial + commonLetterBonus(letter)
        }

        return balance + flexibilityBonus - duplicatePenalty - awkwardPenalty
    }

    func awkwardLetterPenalty(_ letter: String) -> Int {
        switch letter {
        case "Q": return 3
        case "J", "X", "Z": return 2
        case "V", "K", "W", "Y": return 1
        default: return 0
        }
    }

    func commonLetterBonus(_ letter: String) -> Int {
        switch letter {
        case "E", "A", "I", "O", "N", "R", "T", "L", "S":
            return 1
        default:
            return 0
        }
    }

    func discardPriority(for letter: String) -> Int {
        switch letter {
        case "Q": return 9
        case "J", "X", "Z": return 8
        case "V", "K", "W": return 6
        case "U", "Y": return 4
        default: return 1
        }
    }
}
