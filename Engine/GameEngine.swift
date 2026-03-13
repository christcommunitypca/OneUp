import Foundation
import Combine

@MainActor
final class GameEngine: ObservableObject {

    @Published var state: GameState?

    @Published var isMultiplayer: Bool = false
    @Published var inviteCode: String? = nil

    @Published var validationMessage: String? = nil
    @Published var isValidating: Bool = false

    @Published var pendingTurn: PendingTurn = .init()

    @Published var isBlindSwapPromptVisible: Bool = false
    @Published var livePreviewWord: [LetterTile] = []
    @Published var livePreviewIsValid: Bool? = nil
    @Published var roundMessage: String? = nil
    @Published var timerNow: Date = Date()
    
    var cpuTask: Task<Void, Never>?
    var timerTask: Task<Void, Never>?
    var previewValidationTask: Task<Void, Never>?

    let cpuNames = [
        "Mabel", "Otis", "Pearl", "Walter", "Hazel",
        "June", "Frankie", "Ruth", "Archie", "Irene"
    ]

    var myPlayerIndex: Int? {
        guard let state else { return nil }

        if isMultiplayer, let uid = AuthManager.shared.userId {
            return state.players.firstIndex(where: { $0.clerkUserId == uid })
        }

        return state.players.firstIndex(where: { $0.isCurrentDevice })
    }

    var myPlayer: Player? {
        guard let idx = myPlayerIndex, let state else { return nil }
        return state.players[idx]
    }

    var currentPlayer: Player? {
        state?.currentPlayer
    }

    var isMyTurn: Bool {
        guard let state, let mine = myPlayerIndex else { return false }
        return state.currentPlayerIndex == mine && state.phase == .playing
    }

    var visibleHand: [LetterTile] {
        myPlayer?.hand ?? []
    }

    var selectedHandIndices: [Int] {
        pendingTurn.selectedHandIndices
    }

    var hasSingleHandSelection: Bool {
        isMyTurn && pendingTurn.hasSingleSelection
    }

    var hasMultiHandSelection: Bool {
        isMyTurn && pendingTurn.hasMultiSelection
    }

    var canDiscardSelection: Bool {
        guard isMyTurn else { return false }

        if pendingTurn.selectedHandCount > 0 {
            return true
        }

        if state?.currentWord.isEmpty == true,
           !pendingTurn.insertDrafts.isEmpty,
           pendingTurn.swapDrafts.isEmpty {
            return true
        }

        return false
    }

    var canPassTurn: Bool {
        isMyTurn
    }

    var canClearSelection: Bool {
        isMyTurn && !pendingTurn.isEmpty
    }

    var canCommitDraftTurn: Bool {
        isMyTurn && pendingTurn.hasDraftEdits
    }

    var playButtonTitle: String {
        "Play"
    }
    
    var roundTransitionTask: Task<Void, Never>?

    func activeActorIndex(for state: GameState) -> Int? {
        let currentIndex = state.currentPlayerIndex
        guard state.players.indices.contains(currentIndex) else { return nil }

        if state.players[currentIndex].isComputer {
            return currentIndex
        }

        guard let mine = myPlayerIndex, mine == currentIndex else { return nil }
        return mine
    }

    func advanceToNextPlayer(_ state: inout GameState) {
        state.currentPlayerIndex = state.nextPlayerIndex
        state.startTurnTimer()
        timerNow = Date()
    }

    func buildInsertedWord(
        baseWord: [LetterTile],
        selectedTiles: [LetterTile],
        insertionPositions: [Int],
        playerIndex: Int
    ) -> [LetterTile] {
        let orderedPairs = Array(zip(selectedTiles.indices, zip(selectedTiles, insertionPositions)))
            .sorted { lhs, rhs in
                let leftPos = lhs.1.1
                let rightPos = rhs.1.1
                if leftPos == rightPos { return lhs.0 < rhs.0 }
                return leftPos < rightPos
            }
            .map { $0.1 }

        var result: [LetterTile] = []

        for gap in 0...baseWord.count {
            let insertsHere = orderedPairs.filter { $0.1 == gap }
            for pair in insertsHere {
                result.append(LetterTile(letter: pair.0.letter, playerIndex: playerIndex))
            }
            if gap < baseWord.count {
                result.append(baseWord[gap])
            }
        }

        return result
    }

    func combinations<T>(of elements: [T], taking k: Int) -> [[T]] {
        guard k > 0 else { return [[]] }
        guard k <= elements.count else { return [] }
        guard k != elements.count else { return [elements] }

        if let first = elements.first {
            let sub = Array(elements.dropFirst())
            let withFirst = combinations(of: sub, taking: k - 1).map { [first] + $0 }
            let withoutFirst = combinations(of: sub, taking: k)
            return withFirst + withoutFirst
        }

        return []
    }

    func permutations(of elements: [String]) -> [[String]] {
        guard elements.count > 1 else { return [elements] }

        var result: [[String]] = []

        for (index, item) in elements.enumerated() {
            var rest = elements
            rest.remove(at: index)
            for perm in permutations(of: rest) {
                result.append([item] + perm)
            }
        }

        return result
    }
}
