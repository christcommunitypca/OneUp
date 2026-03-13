//
//  GameEngine+CPUPlanning.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

import Foundation

@MainActor
extension GameEngine {
    func findBestCPUMove(
        state: GameState,
        actorIndex: Int,
        profile: CPUProfile
    ) async -> CPUCandidate? {
        let hand = state.players[actorIndex].hand
        guard !hand.isEmpty else { return nil }

        var candidates: [CPUCandidate] = []

        if state.currentWord.isEmpty {
            candidates.append(
                contentsOf: await buildOpeningCandidates(
                    state: state,
                    actorIndex: actorIndex,
                    hand: hand,
                    profile: profile
                )
            )
        } else {
            if profile.allowSingleInsert {
                candidates.append(
                    contentsOf: await buildSingleInsertCandidates(
                        state: state,
                        actorIndex: actorIndex,
                        hand: hand,
                        profile: profile
                    )
                )
            }

            if profile.allowSingleSwap {
                candidates.append(
                    contentsOf: await buildSingleSwapCandidates(
                        state: state,
                        actorIndex: actorIndex,
                        hand: hand,
                        profile: profile
                    )
                )
            }

            if profile.allowDoubleInsert {
                candidates.append(
                    contentsOf: await buildDoubleInsertCandidates(
                        state: state,
                        actorIndex: actorIndex,
                        hand: hand,
                        profile: profile
                    )
                )
            }
        }

        guard !candidates.isEmpty else { return nil }
        return chooseCandidate(from: candidates, style: profile.selectionStyle)
    }

    func buildOpeningCandidates(
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
                    guard await DictionaryService.isValid(word, validationMode: .localOnly) else { continue }

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

                    candidates.append(
                        CPUCandidate(
                            word: word,
                            inserts: inserts,
                            swaps: [],
                            score: score
                        )
                    )
                }
            }
        }

        return candidates
    }

    func buildSingleInsertCandidates(
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
                guard await DictionaryService.isValid(word, validationMode: .localOnly) else { continue }

                let inserts = [DraftInsert(handIndex: handIndex, position: pos, order: 1)]

                let score = scoreCandidate(
                    word: word,
                    hand: hand,
                    currentWord: state.currentWord,
                    inserts: inserts,
                    swaps: [],
                    handQualityWeight: profile.handQualityWeight
                )

                candidates.append(
                    CPUCandidate(
                        word: word,
                        inserts: inserts,
                        swaps: [],
                        score: score
                    )
                )
            }
        }

        return candidates
    }

    func buildSingleSwapCandidates(
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
                guard await DictionaryService.isValid(word, validationMode: .localOnly) else { continue }

                let swaps = [DraftSwap(handIndex: handIndex, wordIndex: wordIndex, order: 1)]

                let score = scoreCandidate(
                    word: word,
                    hand: hand,
                    currentWord: state.currentWord,
                    inserts: [],
                    swaps: swaps,
                    handQualityWeight: profile.handQualityWeight
                )

                candidates.append(
                    CPUCandidate(
                        word: word,
                        inserts: [],
                        swaps: swaps,
                        score: score
                    )
                )
            }
        }

        return candidates
    }

    func buildDoubleInsertCandidates(
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
                        guard await DictionaryService.isValid(word, validationMode: .localOnly) else { continue }

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

                        candidates.append(
                            CPUCandidate(
                                word: word,
                                inserts: inserts,
                                swaps: [],
                                score: score
                            )
                        )
                    }
                }
            }
        }

        return candidates
    }
}
