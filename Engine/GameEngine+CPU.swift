import Foundation

@MainActor
extension GameEngine {

    private enum CPUSelectionStyle {
        case weakestLegal
        case strongestLegal
        case strongestStrategic
    }

    private struct CPUProfile {
        let openingMaxLength: Int
        let allowSingleInsert: Bool
        let allowDoubleInsert: Bool
        let allowSingleSwap: Bool
        let usesDiscardWhenStuck: Bool
        let discardCount: Int
        let selectionStyle: CPUSelectionStyle
        let handQualityWeight: Int
    }

    private struct CPUCandidate {
        let word: String
        let inserts: [DraftInsert]
        let swaps: [DraftSwap]
        let score: Int
    }

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
        let difficulty = state.currentPlayer.cpuDifficulty ?? state.config.defaultCPUDifficulty
        let profile = cpuProfile(for: difficulty)

        if let move = await findBestCPUMove(state: state, actorIndex: currentIndex, profile: profile) {
            await applyCPUMove(move)
            return
        }

        if profile.usesDiscardWhenStuck,
           executeCPUDiscard(actorIndex: currentIndex, discardCount: profile.discardCount) {
            return
        }

        pass()
    }

    private func cpuProfile(for difficulty: CPUDifficulty) -> CPUProfile {
        switch difficulty {
        case .novice:
            return CPUProfile(
                openingMaxLength: 4,
                allowSingleInsert: true,
                allowDoubleInsert: false,
                allowSingleSwap: false,
                usesDiscardWhenStuck: false,
                discardCount: 0,
                selectionStyle: .weakestLegal,
                handQualityWeight: 0
            )
        case .adept:
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
        case .expert:
            return CPUProfile(
                openingMaxLength: 6,
                allowSingleInsert: true,
                allowDoubleInsert: false,
                allowSingleSwap: true,
                usesDiscardWhenStuck: true,
                discardCount: 1,
                selectionStyle: .strongestStrategic,
                handQualityWeight: 2
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

    private func findBestCPUMove(
        state: GameState,
        actorIndex: Int,
        profile: CPUProfile
    ) async -> CPUCandidate? {
        let hand = state.players[actorIndex].hand
        guard !hand.isEmpty else { return nil }

        var candidates: [CPUCandidate] = []

        if state.currentWord.isEmpty {
            candidates.append(contentsOf: await buildOpeningCandidates(state: state, actorIndex: actorIndex, hand: hand, profile: profile))
        } else {
            if profile.allowSingleInsert {
                candidates.append(contentsOf: await buildSingleInsertCandidates(state: state, actorIndex: actorIndex, hand: hand, profile: profile))
            }
            if profile.allowSingleSwap {
                candidates.append(contentsOf: await buildSingleSwapCandidates(state: state, actorIndex: actorIndex, hand: hand, profile: profile))
            }
            if profile.allowDoubleInsert {
                candidates.append(contentsOf: await buildDoubleInsertCandidates(state: state, actorIndex: actorIndex, hand: hand, profile: profile))
            }
        }

        guard !candidates.isEmpty else { return nil }
        return chooseCandidate(from: candidates, style: profile.selectionStyle)
    }

    private func buildOpeningCandidates(
        state: GameState,
        actorIndex: Int,
        hand: [LetterTile],
        profile: CPUProfile
    ) async -> [CPUCandidate] {
        let maxLen = min(profile.openingMaxLength, hand.count)
        guard maxLen >= 2 else { return [] }

        var candidates: [CPUCandidate] = []
        var seen = Set<String>()

        for length in 2...maxLen {
            let combos = combinations(of: Array(hand.enumerated()), taking: length)
            for combo in combos {
                let letters = combo.map(\.element.letter)
                for perm in permutations(of: letters) {
                    let word = perm.joined()
                    guard !state.playedWordsThisRound.contains(word) else { continue }
                    guard seen.insert("open|\(word)").inserted else { continue }
                    guard await DictionaryService.isValid(word, mode: .localOnly) else { continue }

                    var available = combo.map { ($0.offset, $0.element.letter) }
                    var chosenIndices: [Int] = []
                    for letter in perm {
                        if let idx = available.firstIndex(where: { $0.1 == letter }) {
                            chosenIndices.append(available[idx].0)
                            available.remove(at: idx)
                        }
                    }

                    let inserts = chosenIndices.enumerated().map { order, handIndex in
                        DraftInsert(handIndex: handIndex, position: 0, order: order + 1)
                    }

                    let score = scoreCandidate(
                        word: word,
                        hand: hand,
                        currentWord: state.currentWord,
                        inserts: inserts,
                        swaps: [],
                        handQualityWeight: profile.handQualityWeight
                    )
                    candidates.append(CPUCandidate(word: word, inserts: inserts, swaps: [], score: score))
                }
            }
        }

        return candidates
    }

    private func buildSingleInsertCandidates(
        state: GameState,
        actorIndex: Int,
        hand: [LetterTile],
        profile: CPUProfile
    ) async -> [CPUCandidate] {
        let currentWordString = state.currentWord.map(\.letter).joined()
        var candidates: [CPUCandidate] = []
        var seen = Set<String>()

        for (handIndex, tile) in hand.enumerated() {
            for pos in 0...state.currentWord.count {
                let candidateWord = buildInsertedWord(
                    baseWord: state.currentWord,
                    selectedTiles: [tile],
                    insertionPositions: [pos],
                    playerIndex: actorIndex
                )

                let word = candidateWord.map(\.letter).joined()
                guard word != currentWordString else { continue }
                guard !state.playedWordsThisRound.contains(word) else { continue }
                guard seen.insert("insert1|\(word)|\(handIndex)|\(pos)").inserted else { continue }
                guard await DictionaryService.isValid(word, mode: .localOnly) else { continue }

                let inserts = [DraftInsert(handIndex: handIndex, position: pos, order: 1)]
                let score = scoreCandidate(
                    word: word,
                    hand: hand,
                    currentWord: state.currentWord,
                    inserts: inserts,
                    swaps: [],
                    handQualityWeight: profile.handQualityWeight
                )
                candidates.append(CPUCandidate(word: word, inserts: inserts, swaps: [], score: score))
            }
        }

        return candidates
    }

    private func buildSingleSwapCandidates(
        state: GameState,
        actorIndex: Int,
        hand: [LetterTile],
        profile: CPUProfile
    ) async -> [CPUCandidate] {
        let currentWordString = state.currentWord.map(\.letter).joined()
        var candidates: [CPUCandidate] = []
        var seen = Set<String>()

        for (handIndex, tile) in hand.enumerated() {
            for wordIndex in state.currentWord.indices {
                var newWord = state.currentWord
                newWord[wordIndex] = LetterTile(letter: tile.letter, playerIndex: actorIndex)

                let word = newWord.map(\.letter).joined()
                guard word != currentWordString else { continue }
                guard !state.playedWordsThisRound.contains(word) else { continue }
                guard seen.insert("swap1|\(word)|\(handIndex)|\(wordIndex)").inserted else { continue }
                guard await DictionaryService.isValid(word, mode: .localOnly) else { continue }

                let swaps = [DraftSwap(handIndex: handIndex, wordIndex: wordIndex, order: 1)]
                let score = scoreCandidate(
                    word: word,
                    hand: hand,
                    currentWord: state.currentWord,
                    inserts: [],
                    swaps: swaps,
                    handQualityWeight: profile.handQualityWeight
                )
                candidates.append(CPUCandidate(word: word, inserts: [], swaps: swaps, score: score))
            }
        }

        return candidates
    }

    private func buildDoubleInsertCandidates(
        state: GameState,
        actorIndex: Int,
        hand: [LetterTile],
        profile: CPUProfile
    ) async -> [CPUCandidate] {
        guard hand.count >= 2 else { return [] }

        var candidates: [CPUCandidate] = []
        var seen = Set<String>()
        let indexedHand = Array(hand.enumerated())
        let pairs = combinations(of: indexedHand, taking: 2)

        for pair in pairs {
            let first = pair[0]
            let second = pair[1]
            let handOrders = [
                [(first.offset, first.element), (second.offset, second.element)],
                [(second.offset, second.element), (first.offset, first.element)]
            ]

            for firstPos in 0...state.currentWord.count {
                for secondPos in firstPos...state.currentWord.count {
                    for ordered in handOrders {
                        let tiles = ordered.map(\.1)
                        let positions = [firstPos, secondPos]
                        let candidateWord = buildInsertedWord(
                            baseWord: state.currentWord,
                            selectedTiles: tiles,
                            insertionPositions: positions,
                            playerIndex: actorIndex
                        )

                        let word = candidateWord.map(\.letter).joined()
                        guard !state.playedWordsThisRound.contains(word) else { continue }
                        let key = "insert2|\(word)|\(ordered[0].0)|\(ordered[1].0)|\(firstPos)|\(secondPos)"
                        guard seen.insert(key).inserted else { continue }
                        guard await DictionaryService.isValid(word, mode: .localOnly) else { continue }

                        let inserts = [
                            DraftInsert(handIndex: ordered[0].0, position: firstPos, order: 1),
                            DraftInsert(handIndex: ordered[1].0, position: secondPos, order: 2)
                        ]

                        let score = scoreCandidate(
                            word: word,
                            hand: hand,
                            currentWord: state.currentWord,
                            inserts: inserts,
                            swaps: [],
                            handQualityWeight: profile.handQualityWeight
                        )
                        candidates.append(CPUCandidate(word: word, inserts: inserts, swaps: [], score: score))
                    }
                }
            }
        }

        return candidates
    }

    private func chooseCandidate(from candidates: [CPUCandidate], style: CPUSelectionStyle) -> CPUCandidate? {
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
            return sorted.first
        case .strongestLegal, .strongestStrategic:
            return sorted.last
        }
    }

    private func scoreCandidate(
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
        let leftovers = simulatedHandAfterMove(hand: hand, currentWord: currentWord, inserts: inserts, swaps: swaps)
        let handQuality = evaluateHand(leftovers)
        return baseScore + insertBonus + swapBonus + (handQuality * handQualityWeight)
    }

    private func points(forWordLength count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (0..<count).reduce(0) { partial, index in
            partial + (index < 4 ? 1 : 2)
        }
    }

    private func simulatedHandAfterMove(
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
            guard currentWord.indices.contains(swap.wordIndex) else { continue }
            if let existingIndex = leftovers.firstIndex(of: hand[swap.handIndex].letter) {
                leftovers.remove(at: existingIndex)
            }
            leftovers.append(currentWord[swap.wordIndex].letter)
        }

        return leftovers
    }

    private func evaluateHand(_ letters: [String]) -> Int {
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

    private func awkwardLetterPenalty(_ letter: String) -> Int {
        switch letter {
        case "Q": return 3
        case "J", "X", "Z": return 2
        case "V", "K", "W", "Y": return 1
        default: return 0
        }
    }

    private func commonLetterBonus(_ letter: String) -> Int {
        switch letter {
        case "E", "A", "I", "O", "N", "R", "T", "L", "S": return 1
        default: return 0
        }
    }

    private func applyCPUMove(_ move: CPUCandidate) async {
        clearPendingTurn()
        pendingTurn.insertDrafts = move.inserts
        pendingTurn.swapDrafts = move.swaps
        pendingTurn.action = move.swaps.isEmpty ? .insert : .swap
        refreshPendingTurnMirrors()
        updateLivePreview()
        await playSelectedAction()
    }

    @discardableResult
    private func executeCPUDiscard(actorIndex: Int, discardCount: Int) -> Bool {
        guard let state else { return false }
        let hand = state.players[actorIndex].hand
        guard hand.count >= 2, discardCount > 0 else { return false }

        let ranked = hand.enumerated().sorted { lhs, rhs in
            let leftScore = discardPriority(for: lhs.element.letter)
            let rightScore = discardPriority(for: rhs.element.letter)
            if leftScore == rightScore {
                return lhs.offset < rhs.offset
            }
            return leftScore > rightScore
        }

        let indices = ranked.prefix(discardCount).map(\.offset).sorted()
        guard !indices.isEmpty else { return false }

        clearPendingTurn()
        pendingTurn.selectedHandIndices = indices
        refreshPendingTurnMirrors()
        discardSelectedLetters()
        return true
    }

    private func discardPriority(for letter: String) -> Int {
        switch letter {
        case "Q": return 9
        case "J", "X", "Z": return 8
        case "V", "K", "W": return 6
        case "U", "Y": return 4
        default: return 1
        }
    }
}
