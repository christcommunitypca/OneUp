//
//  GameState.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//
import Foundation

struct GameState: Codable {
    var id: UUID
    var players: [Player]
    var drawPile: [LetterTile]
    var discardPile: [LetterTile]
    var currentWord: [LetterTile]
    var currentPlayerIndex: Int
    var consecutivePasses: Int
    var phase: GamePhase
    var winnerName: String?
    var config: GameConfig
    var inviteCode: String?
    var lastEditingPlayerIndex: Int?
    var pendingBlindSwap: PendingBlindSwap?
    var turnStartedAt: Date?
    var turnExpiresAt: Date?
    var playedWordsThisRound: [String]
    var log: [String]

    init(
        id: UUID = UUID(),
        players: [Player],
        drawPile: [LetterTile],
        discardPile: [LetterTile],
        currentWord: [LetterTile],
        currentPlayerIndex: Int,
        consecutivePasses: Int,
        phase: GamePhase,
        winnerName: String? = nil,
        config: GameConfig,
        inviteCode: String? = nil,
        lastEditingPlayerIndex: Int? = nil,
        pendingBlindSwap: PendingBlindSwap? = nil,
        turnStartedAt: Date? = nil,
        turnExpiresAt: Date? = nil,
        playedWordsThisRound: [String] = [],
        log: [String] = []
    ) {
        self.id = id
        self.players = players
        self.drawPile = drawPile
        self.discardPile = discardPile
        self.currentWord = currentWord
        self.currentPlayerIndex = currentPlayerIndex
        self.consecutivePasses = consecutivePasses
        self.phase = phase
        self.winnerName = winnerName
        self.config = config
        self.inviteCode = inviteCode
        self.lastEditingPlayerIndex = lastEditingPlayerIndex
        self.pendingBlindSwap = pendingBlindSwap
        self.turnStartedAt = turnStartedAt
        self.turnExpiresAt = turnExpiresAt
        self.playedWordsThisRound = playedWordsThisRound
        self.log = log
    }

    var currentPlayer: Player {
        players[currentPlayerIndex]
    }

    var wordString: String {
        currentWord.map(\.letter).joined()
    }

    var wordPoints: Int {
        currentWord.enumerated().reduce(0) { partial, entry in
            partial + (entry.offset < 4 ? 1 : 2)
        }
    }

    var nextPlayerIndex: Int {
        guard !players.isEmpty else { return 0 }
        return (currentPlayerIndex + 1) % players.count
    }

    mutating func startTurnTimer(now: Date = Date()) {
        turnStartedAt = now
        if let seconds = config.timer.seconds {
            turnExpiresAt = now.addingTimeInterval(TimeInterval(seconds))
        } else {
            turnExpiresAt = nil
        }
    }

    mutating func clearTurnTimer() {
        turnStartedAt = nil
        turnExpiresAt = nil
    }
}
