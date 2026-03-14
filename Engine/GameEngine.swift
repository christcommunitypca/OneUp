import Foundation
import Combine

@MainActor
final class GameEngine: ObservableObject {

    enum CoachTipID: String, Codable, CaseIterable {
        case tapTileStart
        case tapWhere
        case tapPlay

        case swapTwo
        case swapAdd
        case swapAndAdd

        case lettersFive
        case lettersFivePlus

        case passNow
        case passTakePoints

        case addLetter
        case addLetterMorePoints

        case discard
        case discardBetterLetters
    }
    
    func scheduleCoachEvaluation(after delay: TimeInterval = 1.0) {
        coachEvaluationTask?.cancel()

        coachEvaluationTask = Task { [weak self] in
            guard let self else { return }

            if delay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.timerNow = Date()
                self.refreshCoachTip()
            }
        }
    }

    struct CoachProgress: Codable {
        var completedGames: Int = 0
        var playerTurns: Int = 0
        var shownCounts: [String: Int] = [:]
        var actionCounts: [String: Int] = [:]
    }

    struct CoachTipCandidate {
        let id: CoachTipID
        let text: String
    }

    @Published var state: GameState?

    @Published var isMultiplayer: Bool = false
    @Published var inviteCode: String? = nil

    @Published var validationMessage: String? = nil
    @Published var isValidating: Bool = false

    @Published var pendingTurn: PendingTurn = .init()

    @Published var isBlindSwapPromptVisible: Bool = false
    @Published var livePreviewWord: [LetterTile] = []
    @Published var livePreviewIsValid: Bool? = nil
    @Published var livePreviewAlreadyPlayed: Bool = false
    @Published var roundMessage: String? = nil
    @Published var timerNow: Date = Date()
    @Published var coachTip: String? = nil


    var coachEvaluationTask: Task<Void, Never>?
    var coachHideTask: Task<Void, Never>?
    private var currentCoachTipID: CoachTipID? = nil
    private var coachTurnContext: String = ""
    private var coachTipWasShownThisTurn = false
    
    var cpuTask: Task<Void, Never>?
    var timerTask: Task<Void, Never>?
    var previewValidationTask: Task<Void, Never>?
    
    private let coachProgressKey = "coach_progress_v4"
    private var coachProgress: CoachProgress = {
        guard let data = UserDefaults.standard.data(forKey: "coach_progress_v4"),
              let progress = try? JSONDecoder().decode(CoachProgress.self, from: data) else {
            return CoachProgress()
        }
        return progress
    }()
    private var lastDisplayedCoachTipID: CoachTipID? = nil
    private var lastRecordedCoachTurnToken: String? = nil
    private var lastCompletedCoachGameID: UUID? = nil
    
    let cpuNames = [
        "Mabel", "Otis", "Pearl", "Walter", "Hazel",
        "June", "Frankie", "Ruth", "Archie", "Irene"
    ]

    var myPlayerIndex: Int? {
        guard let state else { return nil }
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

    var coachTipsAreActive: Bool {
        let withinIntroWindow = coachProgress.completedGames < 5 || coachProgress.playerTurns < 30
        let hasPartiallyIntroducedTips = CoachTipID.allCases.contains {
            let count = coachProgress.shownCounts[$0.rawValue, default: 0]
            return count > 0 && count < 2
        }
        return withinIntroWindow || hasPartiallyIntroducedTips
    }
    private func currentCoachTurnContext() -> String {
        guard let state else { return "none" }
        let started = state.turnStartedAt?.timeIntervalSince1970 ?? 0
        return "\(state.currentPlayerIndex)-\(started)"
    }

    private func syncCoachTurnContext() {
        let newContext = currentCoachTurnContext()
        guard newContext != coachTurnContext else { return }

        coachTurnContext = newContext
        coachTipWasShownThisTurn = false
        currentCoachTipID = nil
        coachTip = nil
        coachEvaluationTask?.cancel()
        coachHideTask?.cancel()
    }

    func noteCoachRelevantAction() {
        syncCoachTurnContext()
        coachEvaluationTask?.cancel()
        coachHideTask?.cancel()

        if currentCoachTipID != nil || coachTip != nil {
            coachTipWasShownThisTurn = true
        }

        currentCoachTipID = nil
        coachTip = nil
    }
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

    func refreshCoachTip() {
        let candidate = computeCoachTipCandidate()

        if candidate?.id != lastDisplayedCoachTipID {
            if let id = candidate?.id {
                coachProgress.shownCounts[id.rawValue, default: 0] += 1
                saveCoachProgress()
            }
            lastDisplayedCoachTipID = candidate?.id
        }

        let nextTip = candidate?.text
        if coachTip != nextTip {
            coachTip = nextTip
        }
    }
    
    func clearCoachTip(immediate: Bool = true) {
        coachEvaluationTask?.cancel()
        coachHideTask?.cancel()
        currentCoachTipID = nil
        if immediate {
            coachTip = nil
        }
    }
    
    func evaluateCoachTipNow() {
        syncCoachTurnContext()

        guard !coachTipWasShownThisTurn, coachTip == nil, currentCoachTipID == nil else {
            return
        }

        guard let candidate = coachCandidateForCurrentState() else { return }

        presentCoachTip(candidate.id, text: candidate.text, duration: 7.5)
    }
   
    private func presentCoachTip(_ id: CoachTipID, text: String, duration: TimeInterval) {
        guard !coachTipWasShownThisTurn else { return }
        guard shouldShowCoachTip(id) else { return }

        coachProgress.shownCounts[id.rawValue, default: 0] += 1
        saveCoachProgress()

        currentCoachTipID = id
        coachTipWasShownThisTurn = true
        coachTip = text

        coachHideTask?.cancel()
        coachHideTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                if self.currentCoachTipID == id {
                    self.coachTip = nil
                    self.currentCoachTipID = nil
                }
            }
        }
    }

    private func coachCandidateForCurrentState() -> (id: CoachTipID, text: String)? {
        guard let state, state.phase == .playing, isMyTurn else { return nil }

        if pendingTurn.hasDraftEdits {
            if !pendingTurn.swapDrafts.isEmpty,
               pendingTurn.insertDrafts.isEmpty,
               shouldShowCoachTip(.swapAndAdd) {
                return (.swapAndAdd, "Swap and add letters to form a new word")
            }

            if shouldShowCoachTip(.tapPlay) {
                return (.tapPlay, "Tap Play to make this move")
            }
        }

        if pendingTurn.hasSingleSelection, shouldShowCoachTip(.tapWhere) {
            return (.tapWhere, "Tap where the letter should go")
        }

        if state.currentWord.count >= 5, shouldShowCoachTip(.lettersFive) {
            return (.lettersFive, "Letters 5+ score two points")
        }

        let passEndsRound = state.consecutivePasses + 1 >= state.players.count && !state.currentWord.isEmpty
        if passEndsRound {
            if coachShownCount(.passNow) < 2 || (coachIntroIsActive && shouldShowCoachTip(.passNow)) {
                return (.passNow, "Pass to take the points now")
            }

            if shouldShowCoachTip(.addLetter) {
                return (.addLetter, "Add a letter to go for more points")
            }
        }

        if !state.currentWord.isEmpty,
           pendingTurn.isEmpty,
           shouldShowCoachTip(.swapTwo) {
            return (.swapTwo, "Swap up to two letters at a time")
        }

        if !state.currentWord.isEmpty,
           pendingTurn.isEmpty,
           shouldShowCoachTip(.discard) {
            return (.discard, "Discard if you need better letters")
        }

        if pendingTurn.isEmpty, shouldShowCoachTip(.tapTileStart) {
            return (.tapTileStart, "Tap a tile to start")
        }

        return nil
    }
    
    func shouldShowCoachTip(_ id: CoachTipID) -> Bool {
        let count = coachShownCount(id)
        let maxShows = coachIntroIsActive ? 3 : 2
        return count < maxShows
    }
    
    var coachIntroIsActive: Bool {
        coachProgress.completedGames < 5 || coachProgress.playerTurns < 30
    }
    
    func coachShownCount(_ id: CoachTipID) -> Int {
        coachProgress.shownCounts[id.rawValue, default: 0]
    }
    
    func registerCoachTurnIfNeeded(for state: GameState) {
        guard let mine = myPlayerIndex else { return }
        guard state.currentPlayerIndex == mine else { return }
        guard let startedAt = state.turnStartedAt else { return }

        let token = "\(state.id.uuidString)-\(mine)-\(startedAt.timeIntervalSince1970)"
        guard token != lastRecordedCoachTurnToken else { return }

        lastRecordedCoachTurnToken = token
        coachProgress.playerTurns += 1
        saveCoachProgress()
    }

    func markCoachGameCompletedIfNeeded(for state: GameState) {
        guard state.phase == .gameOver else { return }
        guard lastCompletedCoachGameID != state.id else { return }

        lastCompletedCoachGameID = state.id
        coachProgress.completedGames += 1
        saveCoachProgress()
    }

    func recordCoachAction(_ id: CoachTipID) {
        coachProgress.actionCounts[id.rawValue, default: 0] += 1
        saveCoachProgress()
    }

    func canBankPointsOnPassNow(in state: GameState) -> Bool {
        guard let mine = myPlayerIndex else { return false }
        guard state.currentPlayerIndex == mine else { return false }
        guard !state.currentWord.isEmpty else { return false }
        guard state.lastEditingPlayerIndex == mine else { return false }
        return state.consecutivePasses + 1 >= state.players.count
    }

    func recordCoachTurnCompletedIfNeeded(actorIndex: Int) {
        guard let mine = myPlayerIndex, mine == actorIndex else { return }

        let turnsKey = "coach_progress_v4_turns"
        let currentTurns = UserDefaults.standard.integer(forKey: turnsKey)
        UserDefaults.standard.set(currentTurns + 1, forKey: turnsKey)

        clearCoachTip(immediate: true)
    }

    func recordCoachGameCompleted() {
        let gamesKey = "coach_progress_v4_games"
        let currentGames = UserDefaults.standard.integer(forKey: gamesKey)
        UserDefaults.standard.set(currentGames + 1, forKey: gamesKey)

        clearCoachTip(immediate: true)
    }
    
    private func saveCoachProgress() {
        guard let data = try? JSONEncoder().encode(coachProgress) else { return }
        UserDefaults.standard.set(data, forKey: coachProgressKey)
    }

    private func computeCoachTipCandidate() -> CoachTipCandidate? {
        guard coachTipsAreActive else { return nil }
        guard let state else { return nil }
        guard state.phase == .playing else { return nil }
        guard isMyTurn else { return nil }

        let idleSeconds = playerIdleSeconds(in: state)
        let currentWordLength = max(state.currentWord.count, livePreviewWord.count)
        let previewIsLiveInvalid = state.config.wordHintsEnabled && !livePreviewWord.isEmpty && livePreviewIsValid == false
        let previewBlocksPlay = livePreviewAlreadyPlayed || previewIsLiveInvalid

        if pendingTurn.hasDraftEdits,
           !previewBlocksPlay,
           idleSeconds >= 4,
           shouldOfferCoachTip(.tapPlay, maxShows: 2, retireAfterActions: 2) {
            return CoachTipCandidate(id: .tapPlay, text: "Tap Play to make this move")
        }

        if pendingTurn.hasSingleSelection,
           !pendingTurn.hasDraftEdits,
           idleSeconds >= 3,
           shouldOfferCoachTip(.tapWhere, maxShows: 2, retireAfterActions: 2) {
            return CoachTipCandidate(id: .tapWhere, text: "Tap where the letter should go")
        }

        if canBankPointsOnPassNow(in: state),
           shownCount(for: .passTakePoints) > 0,
           wouldWinByPassingNow(in: state),
           idleSeconds >= 6,
           shouldOfferCoachTip(.addLetterMorePoints, maxShows: 2) {
            return CoachTipCandidate(id: .addLetterMorePoints, text: "Add a letter to go for more points")
        }

        if canBankPointsOnPassNow(in: state),
           idleSeconds >= 6,
           shouldOfferCoachTip(.passTakePoints, maxShows: 2, retireAfterActions: 1) {
            return CoachTipCandidate(id: .passTakePoints, text: "Pass to take the points now")
        }

        if currentWordLength >= 5,
           idleSeconds >= 1,
           shouldOfferCoachTip(.lettersFivePlus, maxShows: 2) {
            return CoachTipCandidate(id: .lettersFivePlus, text: "Letters 5+ score two points")
        }

        if !pendingTurn.hasDraftEdits,
           pendingTurn.selectedHandCount == 0,
           !state.currentWord.isEmpty,
           idleSeconds >= 8,
           shouldOfferCoachTip(.swapTwo, maxShows: 2) {
            return CoachTipCandidate(id: .swapTwo, text: "Swap up to two letters at a time")
        }

        if !pendingTurn.hasDraftEdits,
           pendingTurn.selectedHandCount == 0,
           !state.currentWord.isEmpty,
           shownCount(for: .swapTwo) > 0,
           idleSeconds >= 9,
           shouldOfferCoachTip(.swapAdd, maxShows: 2) {
            return CoachTipCandidate(id: .swapAdd, text: "Swap and add letters to form a new word")
        }

        if !pendingTurn.hasDraftEdits,
           pendingTurn.selectedHandCount == 0,
           idleSeconds >= 10,
           shouldOfferCoachTip(.discardBetterLetters, maxShows: 2, retireAfterActions: 2) {
            return CoachTipCandidate(id: .discardBetterLetters, text: "Discard if you need better letters")
        }

        if pendingTurn.selectedHandCount == 0,
           idleSeconds >= 4,
           shouldOfferCoachTip(.tapTileStart, maxShows: 2, retireAfterActions: 2) {
            return CoachTipCandidate(id: .tapTileStart, text: "Tap a tile to start")
        }

        return nil
    }

    private func playerIdleSeconds(in state: GameState) -> TimeInterval {
        guard let startedAt = state.turnStartedAt else { return 0 }
        return max(0, timerNow.timeIntervalSince(startedAt))
    }

    private func wouldWinByPassingNow(in state: GameState) -> Bool {
        guard canBankPointsOnPassNow(in: state),
              let mine = myPlayerIndex,
              state.players.indices.contains(mine) else {
            return false
        }

        return state.players[mine].score + state.wordPoints >= state.config.winScore
    }

    private func shouldOfferCoachTip(
        _ id: CoachTipID,
        maxShows: Int,
        retireAfterActions: Int? = nil
    ) -> Bool {
        let shown = shownCount(for: id)
        let minimumIntroShows = 2
        let effectiveMaxShows = max(maxShows, minimumIntroShows)

        if shown >= effectiveMaxShows {
            return false
        }

        if shown < minimumIntroShows {
            return true
        }

        if let retireAfterActions,
           actionCount(for: id) >= retireAfterActions {
            return false
        }

        return true
    }

    private func shownCount(for id: CoachTipID) -> Int {
        coachProgress.shownCounts[id.rawValue, default: 0]
    }

    private func actionCount(for id: CoachTipID) -> Int {
        coachProgress.actionCounts[id.rawValue, default: 0]
    }
}
