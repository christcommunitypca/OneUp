import Foundation
import SwiftUI

struct LetterTile: Identifiable, Equatable, Codable {
    let id: UUID
    var letter: String
    var playerIndex: Int

    init(id: UUID = UUID(), letter: String, playerIndex: Int = -1) {
        self.id = id
        self.letter = letter.uppercased()
        self.playerIndex = playerIndex
    }

    var isVowel: Bool {
        "AEIOU".contains(letter)
    }
}

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var hand: [LetterTile]
    var score: Int
    var isComputer: Bool
    var cpuDifficulty: CPUDifficulty?
    var clerkUserId: String?
    var isCurrentDevice: Bool

    init(
        id: UUID = UUID(),
        name: String,
        hand: [LetterTile] = [],
        score: Int = 0,
        isComputer: Bool = false,
        cpuDifficulty: CPUDifficulty? = nil,
        clerkUserId: String? = nil,
        isCurrentDevice: Bool = false
    ) {
        self.id = id
        self.name = name
        self.hand = hand
        self.score = score
        self.isComputer = isComputer
        self.cpuDifficulty = cpuDifficulty
        self.clerkUserId = clerkUserId
        self.isCurrentDevice = isCurrentDevice
    }

    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Player" : name
    }
}

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case easy = "Easy"
    case hard = "Hard"

    var id: String { rawValue }
}

enum CPUDifficulty: String, Codable, CaseIterable, Identifiable {
    case novice = "Novice"
    case adept = "Adept"
    case expert = "Expert"
    case master = "Master"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .novice: return "Novice"
        case .adept: return "Adept"
        case .expert: return "Expert"
        case .master: return "Master"
        }
    }
}

struct CPUSetup: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var difficulty: CPUDifficulty

    init(id: UUID = UUID(), name: String, difficulty: CPUDifficulty) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
    }
}

enum TurnTimerOption: Int, Codable, CaseIterable, Identifiable {
    case off = 0
    case ten = 10
    case fifteen = 15
    case twenty = 20
    case thirty = 30
    case fortyFive = 45
    case sixty = 60

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .off: return "Off"
        default: return "\(rawValue)s"
        }
    }

    var seconds: Int? {
        self == .off ? nil : rawValue
    }
}

struct GameConfig: Codable, Equatable {
    var mode: GameMode
    var defaultCPUDifficulty: CPUDifficulty
    var timer: TurnTimerOption
    var allowBlindSwapAfterTimeout: Bool
    var handSize: Int
    var winScore: Int

    init(
        mode: GameMode = .easy,
        defaultCPUDifficulty: CPUDifficulty = .adept,
        timer: TurnTimerOption = .off,
        allowBlindSwapAfterTimeout: Bool = true,
        handSize: Int = 7,
        winScore: Int = 20
    ) {
        self.mode = mode
        self.defaultCPUDifficulty = defaultCPUDifficulty
        self.timer = timer
        self.allowBlindSwapAfterTimeout = allowBlindSwapAfterTimeout
        self.handSize = handSize
        self.winScore = winScore
    }
}

enum PendingAction: String, Codable {
    case none
    case insert
    case swap
    case discard
}

struct DraftInsert: Identifiable, Codable, Equatable {
    let id: UUID
    let handIndex: Int
    let position: Int
    let order: Int

    init(id: UUID = UUID(), handIndex: Int, position: Int, order: Int) {
        self.id = id
        self.handIndex = handIndex
        self.position = position
        self.order = order
    }
}

struct DraftSwap: Identifiable, Codable, Equatable {
    let id: UUID
    let handIndex: Int
    let wordIndex: Int
    let order: Int

    init(id: UUID = UUID(), handIndex: Int, wordIndex: Int, order: Int) {
        self.id = id
        self.handIndex = handIndex
        self.wordIndex = wordIndex
        self.order = order
    }
}

struct PendingTurn: Codable, Equatable {
    var action: PendingAction

    var activeHandIndex: Int?

    var selectedHandIndices: [Int]
    var selectedWordIndices: [Int]
    var insertionPositions: [Int]

    var insertDrafts: [DraftInsert]
    var swapDrafts: [DraftSwap]
    var discardSelection: [Int]

    init(
        action: PendingAction = .none,
        activeHandIndex: Int? = nil,
        selectedHandIndices: [Int] = [],
        selectedWordIndices: [Int] = [],
        insertionPositions: [Int] = [],
        insertDrafts: [DraftInsert] = [],
        swapDrafts: [DraftSwap] = [],
        discardSelection: [Int] = []
    ) {
        self.action = action
        self.activeHandIndex = activeHandIndex
        self.selectedHandIndices = selectedHandIndices
        self.selectedWordIndices = selectedWordIndices
        self.insertionPositions = insertionPositions
        self.insertDrafts = insertDrafts
        self.swapDrafts = swapDrafts
        self.discardSelection = discardSelection
    }

    var hasDraftEdits: Bool {
        !insertDrafts.isEmpty || !swapDrafts.isEmpty
    }

    var selectedHandCount: Int {
        Set(selectedHandIndices).count
    }

    var hasSingleSelection: Bool {
        selectedHandCount == 1
    }

    var hasMultiSelection: Bool {
        selectedHandCount >= 2
    }

    var swapCount: Int {
        swapDrafts.count
    }

    var canAddAnotherSwap: Bool {
        swapDrafts.count < 2
    }

    var isEmpty: Bool {
        activeHandIndex == nil &&
        selectedHandIndices.isEmpty &&
        selectedWordIndices.isEmpty &&
        insertionPositions.isEmpty &&
        insertDrafts.isEmpty &&
        swapDrafts.isEmpty &&
        discardSelection.isEmpty &&
        action == .none
    }
}

struct PendingBlindSwap: Codable, Equatable {
    var timedOutPlayerIndex: Int
    var eligiblePlayerIndex: Int
    var isAvailable: Bool

    init(timedOutPlayerIndex: Int, eligiblePlayerIndex: Int, isAvailable: Bool = true) {
        self.timedOutPlayerIndex = timedOutPlayerIndex
        self.eligiblePlayerIndex = eligiblePlayerIndex
        self.isAvailable = isAvailable
    }
}

enum GameAction: String, Codable {
    case play
    case swap
    case discard
    case pass
    case timeout
    case blindSwap
    case roundEnd
    case gameOver
}

struct GameMove: Codable {
    let playerId: UUID
    let action: GameAction
    let summary: String
    let timestamp: Date

    init(playerId: UUID, action: GameAction, summary: String, timestamp: Date = Date()) {
        self.playerId = playerId
        self.action = action
        self.summary = summary
        self.timestamp = timestamp
    }
}

enum GamePhase: String, Codable {
    case setup
    case playing
    case roundOver
    case gameOver
}

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
