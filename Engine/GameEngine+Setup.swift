//
//  GameEngine+Setup.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

import Foundation

@MainActor
extension GameEngine {
    func newLocalGame(
        playerNames: [String],
        cpuCount: Int,
        config: GameConfig,
        humanClerkId: String?
    ) {
        let cpuPlayers = (0..<cpuCount).map { index in
            CPUSetup(
                name: cpuNames[index % cpuNames.count],
                difficulty: config.defaultCPUDifficulty
            )
        }

        newLocalGame(
            playerNames: playerNames,
            cpuPlayers: cpuPlayers,
            config: config,
            humanClerkId: humanClerkId
        )
    }

    func newLocalGame(
        playerNames: [String],
        cpuPlayers: [CPUSetup],
        config: GameConfig,
        humanClerkId: String?
    ) {
        var players: [Player] = []

        for (index, rawName) in playerNames.enumerated() {
            let cleaned = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedName = cleaned.isEmpty
                ? (index == 0 ? "You" : "Player \(index + 1)")
                : cleaned

            players.append(
                Player(
                    name: resolvedName,
                    hand: [],
                    score: 0,
                    isComputer: false,
                    cpuDifficulty: nil,
                    clerkUserId: index == 0 ? humanClerkId : nil,
                    isCurrentDevice: index == 0
                )
            )
        }

        for cpu in cpuPlayers {
            players.append(
                Player(
                    name: cpu.name,
                    hand: [],
                    score: 0,
                    isComputer: true,
                    cpuDifficulty: cpu.difficulty,
                    clerkUserId: nil,
                    isCurrentDevice: false
                )
            )
        }

        let dealt = LetterDeck.deal(to: players.count, handSize: config.handSize)
        for i in players.indices {
            players[i].hand = dealt.hands[i]
        }

        var newState = GameState(
            players: players,
            drawPile: dealt.drawPile,
            discardPile: [],
            currentWord: [],
            currentPlayerIndex: 0,
            consecutivePasses: 0,
            phase: .playing,
            winnerName: nil,
            config: config,
            inviteCode: nil,
            lastEditingPlayerIndex: nil,
            pendingBlindSwap: nil,
            turnStartedAt: nil,
            turnExpiresAt: nil,
            playedWordsThisRound: [],
            log: ["Game started"]
        )

        newState.startTurnTimer()

        state = newState
        inviteCode = nil
        isMultiplayer = false
        clearPendingTurn()
        validationMessage = nil
        roundMessage = nil
        coachTip = nil
        scheduleTurnTimerIfNeeded()
        scheduleCPUIfNeeded()
        refreshCoachTip()
    }
}
