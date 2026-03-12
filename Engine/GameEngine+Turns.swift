import Foundation

@MainActor
extension GameEngine {

    enum TurnEndReason {
        case edit
        case discard
        case pass
    }

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
        scheduleTurnTimerIfNeeded()
        scheduleCPUIfNeeded()
    }

    private func nextDraftOrder() -> Int {
        let maxInsert = pendingTurn.insertDrafts.map(\.order).max() ?? 0
        let maxSwap = pendingTurn.swapDrafts.map(\.order).max() ?? 0
        return max(maxInsert, maxSwap) + 1
    }

    func refreshPendingTurnMirrors() {
        pendingTurn.selectedHandIndices = pendingTurn.selectedHandIndices
            .filter { handIndex in
                !pendingTurn.insertDrafts.contains(where: { $0.handIndex == handIndex }) &&
                !pendingTurn.swapDrafts.contains(where: { $0.handIndex == handIndex })
            }
            .sorted()

        if let active = pendingTurn.activeHandIndex,
           !pendingTurn.selectedHandIndices.contains(active) {
            pendingTurn.activeHandIndex = nil
        }

        pendingTurn.selectedWordIndices = pendingTurn.swapDrafts.map(\.wordIndex).sorted()
        pendingTurn.insertionPositions = pendingTurn.insertDrafts.map(\.position).sorted()
        pendingTurn.discardSelection = pendingTurn.selectedHandIndices.sorted()
    }

    private func buildDraftPreviewWord(
        state: GameState,
        actorIndex: Int
    ) -> [LetterTile]? {
        let hand = state.players[actorIndex].hand

        for draft in pendingTurn.insertDrafts where !hand.indices.contains(draft.handIndex) {
            return nil
        }
        for draft in pendingTurn.swapDrafts where !hand.indices.contains(draft.handIndex) {
            return nil
        }

        if state.currentWord.isEmpty {
            let sortedOpeningInserts = pendingTurn.insertDrafts.sorted(by: { $0.order < $1.order })
            guard !sortedOpeningInserts.isEmpty else { return [] }

            return sortedOpeningInserts.map { draft in
                let tile = hand[draft.handIndex]
                return LetterTile(letter: tile.letter, playerIndex: actorIndex)
            }
        }

        var baseWord = state.currentWord

        for swap in pendingTurn.swapDrafts.sorted(by: { $0.order < $1.order }) {
            guard baseWord.indices.contains(swap.wordIndex) else { return nil }
            let tile = hand[swap.handIndex]
            baseWord[swap.wordIndex] = LetterTile(letter: tile.letter, playerIndex: actorIndex)
        }

        let sortedInserts = pendingTurn.insertDrafts.sorted(by: { $0.order < $1.order })
        let insertTiles = sortedInserts.map { hand[$0.handIndex] }
        let insertPositions = sortedInserts.map(\.position)

        if insertTiles.isEmpty {
            return baseWord
        }

        return buildInsertedWord(
            baseWord: baseWord,
            selectedTiles: insertTiles,
            insertionPositions: insertPositions,
            playerIndex: actorIndex
        )
    }

    func publishAndSchedule(_ state: GameState) {
        self.state = state

        Task {
            await syncIfMultiplayer()
        }

        switch state.phase {
        case .playing:
            scheduleTurnTimerIfNeeded()
            scheduleCPUIfNeeded()

        case .roundOver:
            scheduleNextRoundStart()

        case .gameOver:
            timerTask?.cancel()

        default:
            break
        }
    }

    func scheduleNextRoundStart() {
        roundTransitionTask?.cancel()

        roundTransitionTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard let self else { return }
            guard var state = self.state else { return }
            guard state.phase == .roundOver else { return }

            state.currentWord.removeAll()
            state.consecutivePasses = 0
            state.pendingBlindSwap = nil
            state.lastEditingPlayerIndex = nil
            state.playedWordsThisRound = []
            state.phase = .playing
            state.startTurnTimer()

            self.roundMessage = nil
            self.state = state

            await self.syncIfMultiplayer()
            self.scheduleTurnTimerIfNeeded()
            self.scheduleCPUIfNeeded()
        }
    }

    func finishTurn(
        _ state: inout GameState,
        actorIndex: Int,
        reason: TurnEndReason
    ) {
        clearPendingTurn()
        state.pendingBlindSwap = nil

        switch reason {
        case .edit:
            state.consecutivePasses = 0
            advanceToNextPlayer(&state)

        case .discard, .pass:
            state.consecutivePasses += 1

            if state.consecutivePasses >= state.players.count {
                endRound(&state, lastPasserIndex: actorIndex)
            } else {
                advanceToNextPlayer(&state)
            }
        }
    }

    func toggleHandSelection(at handIndex: Int) {
        guard isMyTurn, let state, let mine = myPlayerIndex else { return }
        guard state.players[mine].hand.indices.contains(handIndex) else { return }

        roundMessage = nil
        validationMessage = nil

        if state.currentWord.isEmpty {
            if let existing = pendingTurn.insertDrafts.firstIndex(where: { $0.handIndex == handIndex }) {
                pendingTurn.insertDrafts.remove(at: existing)
                pendingTurn.action = .none
                refreshPendingTurnMirrors()
                updateLivePreview()
                return
            }

            pendingTurn.insertDrafts.append(
                DraftInsert(handIndex: handIndex, position: 0, order: nextDraftOrder())
            )
            pendingTurn.action = .none
            pendingTurn.activeHandIndex = nil
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        if let existing = pendingTurn.insertDrafts.firstIndex(where: { $0.handIndex == handIndex }) {
            pendingTurn.insertDrafts.remove(at: existing)
            pendingTurn.action = .none
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        if let existing = pendingTurn.swapDrafts.firstIndex(where: { $0.handIndex == handIndex }) {
            pendingTurn.swapDrafts.remove(at: existing)
            pendingTurn.action = .none
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        if pendingTurn.selectedHandIndices.contains(handIndex) {
            pendingTurn.selectedHandIndices.removeAll { $0 == handIndex }
            if pendingTurn.activeHandIndex == handIndex {
                pendingTurn.activeHandIndex = nil
            }
            pendingTurn.action = .none
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        pendingTurn.selectedHandIndices.append(handIndex)
        pendingTurn.selectedHandIndices = Array(Set(pendingTurn.selectedHandIndices)).sorted()

        if pendingTurn.selectedHandCount == 1 {
            pendingTurn.activeHandIndex = handIndex
        } else {
            pendingTurn.activeHandIndex = nil
        }

        pendingTurn.action = .none
        refreshPendingTurnMirrors()
        updateLivePreview()
    }

    func chooseInsertPosition(_ position: Int) {
        guard isMyTurn, let state else { return }
        guard pendingTurn.hasSingleSelection, let handIndex = pendingTurn.selectedHandIndices.first else { return }

        roundMessage = nil
        validationMessage = nil

        if state.currentWord.isEmpty {
            pendingTurn.insertDrafts.append(
                DraftInsert(handIndex: handIndex, position: 0, order: nextDraftOrder())
            )
            pendingTurn.selectedHandIndices.removeAll { $0 == handIndex }
            pendingTurn.activeHandIndex = nil
            pendingTurn.action = .none
            refreshPendingTurnMirrors()
            updateLivePreview()
            return
        }

        guard let basePosition = baseWordGapPositionForVisibleGap(
            position,
            baseWordCount: state.currentWord.count
        ) else {
            validationMessage = "Choose a gap between board letters"
            return
        }

        pendingTurn.insertDrafts.append(
            DraftInsert(handIndex: handIndex, position: basePosition, order: nextDraftOrder())
        )
        pendingTurn.selectedHandIndices.removeAll { $0 == handIndex }
        pendingTurn.activeHandIndex = nil
        pendingTurn.action = .none
        refreshPendingTurnMirrors()
        updateLivePreview()
    }

    func chooseSwapMode() {
    }

    func chooseDiscardMode() {
    }

    func chooseWordIndexForSwap(_ wordIndex: Int) {
        guard isMyTurn else { return }
        guard let state else { return }
        guard !state.currentWord.isEmpty else { return }
        guard pendingTurn.hasSingleSelection, let handIndex = pendingTurn.selectedHandIndices.first else { return }
        guard pendingTurn.canAddAnotherSwap else {
            validationMessage = "You can swap at most 2 letters"
            return
        }

        roundMessage = nil
        validationMessage = nil

        guard let baseWordIndex = baseWordIndexForVisibleSwapIndex(
            wordIndex,
            baseWordCount: state.currentWord.count
        ) else {
            return
        }

        pendingTurn.swapDrafts.removeAll { $0.wordIndex == baseWordIndex }

        pendingTurn.swapDrafts.append(
            DraftSwap(handIndex: handIndex, wordIndex: baseWordIndex, order: nextDraftOrder())
        )

        pendingTurn.selectedHandIndices.removeAll { $0 == handIndex }
        pendingTurn.activeHandIndex = nil
        pendingTurn.action = .none

        refreshPendingTurnMirrors()
        updateLivePreview()
    }

    func discardSelectedLetters() {
        guard var state else { return }
        guard let actorIndex = activeActorIndex(for: state) else { return }

        let drafted = Set(pendingTurn.insertDrafts.map(\.handIndex) + pendingTurn.swapDrafts.map(\.handIndex))
        let selected = Set(pendingTurn.selectedHandIndices)

        let discardIndices: [Int]
        if state.currentWord.isEmpty && selected.isEmpty && !pendingTurn.insertDrafts.isEmpty && pendingTurn.swapDrafts.isEmpty {
            discardIndices = pendingTurn.insertDrafts.map(\.handIndex).sorted()
        } else {
            discardIndices = Array(selected.subtracting(drafted)).sorted()
        }

        guard !discardIndices.isEmpty else {
            validationMessage = "Select cards to discard"
            return
        }

        var actorHand = state.players[actorIndex].hand

        LetterDeck.rebuildDrawPileIfNeeded(drawPile: &state.drawPile, discardPile: &state.discardPile)
        LetterDeck.discardAndDraw(
            hand: &actorHand,
            discardIndices: discardIndices,
            drawPile: &state.drawPile,
            discardPile: &state.discardPile
        )
        LetterDeck.rebuildDrawPileIfNeeded(drawPile: &state.drawPile, discardPile: &state.discardPile)

        state.players[actorIndex].hand = actorHand
        state.log.insert("\(state.players[actorIndex].displayName) discarded \(discardIndices.count) card(s)", at: 0)

        validationMessage = nil
        roundMessage = nil

        finishTurn(&state, actorIndex: actorIndex, reason: .discard)
        publishAndSchedule(state)
    }

    func clearPendingTurn() {
        pendingTurn = .init()
        livePreviewWord = []
        livePreviewIsValid = nil
    }

    func playSelectedAction() async {
        await commitDraftTurn()
    }

    private func baseWordGapPositionForVisibleGap(
        _ visibleGap: Int,
        baseWordCount: Int
    ) -> Int? {
        let insertsByPosition = Dictionary(grouping: pendingTurn.insertDrafts, by: \.position)
        var visibleGapCursor = 0

        for gap in 0...baseWordCount {
            let insertsHere = (insertsByPosition[gap] ?? []).sorted { $0.order < $1.order }
            let visibleGapCountForThisBaseGap = 1 + insertsHere.count

            if visibleGapCursor...(visibleGapCursor + visibleGapCountForThisBaseGap - 1) ~= visibleGap {
                return gap
            }

            visibleGapCursor += visibleGapCountForThisBaseGap
        }

        return nil
    }

    private func baseWordIndexForVisibleSwapIndex(
        _ visibleIndex: Int,
        baseWordCount: Int
    ) -> Int? {
        let insertsByPosition = Dictionary(grouping: pendingTurn.insertDrafts, by: \.position)
        var visibleCursor = 0

        for gap in 0...baseWordCount {
            let insertsHere = (insertsByPosition[gap] ?? []).sorted { $0.order < $1.order }

            for _ in insertsHere {
                if visibleCursor == visibleIndex {
                    return nil
                }
                visibleCursor += 1
            }

            if gap < baseWordCount {
                if visibleCursor == visibleIndex {
                    return gap
                }
                visibleCursor += 1
            }
        }

        return nil
    }

    private func commitDraftTurn() async {
        guard var state else { return }
        guard let actorIndex = activeActorIndex(for: state) else { return }
        guard pendingTurn.hasDraftEdits else { return }

        let originalWord = state.currentWord
        let handBefore = state.players[actorIndex].hand

        guard let previewWord = buildDraftPreviewWord(state: state, actorIndex: actorIndex) else {
            validationMessage = "Turn could not be built"
            return
        }

        let newWordString = previewWord.map(\.letter).joined()
        let originalWordString = originalWord.map(\.letter).joined()

        guard newWordString != originalWordString else {
            validationMessage = "Turn must change the word"
            return
        }

        guard !state.playedWordsThisRound.contains(newWordString) else {
            validationMessage = "That word was already played this round"
            return
        }

        isValidating = true
        validationMessage = "Checking \"\(newWordString)\"..."

        let valid = await DictionaryService.isValid(newWordString, mode: .localThenAPI)
        isValidating = false

        guard valid else {
            validationMessage = "\"\(newWordString)\" is not a valid word"
            return
        }

        var newHand = handBefore

        let sortedSwaps = pendingTurn.swapDrafts.sorted(by: { $0.order < $1.order })
        for swap in sortedSwaps {
            guard newHand.indices.contains(swap.handIndex) else { continue }
            guard originalWord.indices.contains(swap.wordIndex) else { continue }

            let removedBoardTile = originalWord[swap.wordIndex]
            newHand[swap.handIndex] = LetterTile(letter: removedBoardTile.letter, playerIndex: -1)
        }

        let insertedIndices = Set(pendingTurn.insertDrafts.map(\.handIndex))
        for index in insertedIndices.sorted(by: >) {
            guard newHand.indices.contains(index) else { continue }
            newHand.remove(at: index)
        }

        LetterDeck.rebuildDrawPileIfNeeded(drawPile: &state.drawPile, discardPile: &state.discardPile)
        LetterDeck.refillHand(&newHand, from: &state.drawPile, targetSize: state.config.handSize)

        state.players[actorIndex].hand = newHand
        state.currentWord = previewWord
        state.lastEditingPlayerIndex = actorIndex
        state.playedWordsThisRound.append(newWordString)
        state.log.insert("\(state.players[actorIndex].displayName) played → \(newWordString)", at: 0)

        validationMessage = nil
        roundMessage = nil

        finishTurn(&state, actorIndex: actorIndex, reason: .edit)
        publishAndSchedule(state)
    }

    func confirmDiscard() {
        discardSelectedLetters()
    }

    func confirmSwap() async {
        await commitDraftTurn()
    }

    func pass() {
        guard var state else { return }
        guard let actorIndex = activeActorIndex(for: state) else { return }

        validationMessage = nil
        roundMessage = nil
        clearPendingTurn()
        state.log.insert("\(state.players[actorIndex].displayName) passed", at: 0)

        finishTurn(&state, actorIndex: actorIndex, reason: .pass)
        publishAndSchedule(state)
    }

    func endRound(_ state: inout GameState, lastPasserIndex: Int) {
        timerTask?.cancel()

        guard !state.players.isEmpty else { return }

        if state.currentWord.isEmpty {
            let nextStarter = (lastPasserIndex + 1) % state.players.count

            for index in state.players.indices {
                LetterDeck.rebuildDrawPileIfNeeded(drawPile: &state.drawPile, discardPile: &state.discardPile)
                let drawn = LetterDeck.draw(1, from: &state.drawPile)
                state.players[index].hand.append(contentsOf: drawn)
            }

            state.pendingBlindSwap = nil
            state.lastEditingPlayerIndex = nil
            state.playedWordsThisRound = []
            state.currentPlayerIndex = nextStarter
            state.phase = .roundOver
            state.clearTurnTimer()
            roundMessage = "Round over. No word built. Everyone drew 1."
            return
        }

        let scorerIndex: Int
        if let lastEditor = state.lastEditingPlayerIndex,
           state.players.indices.contains(lastEditor) {
            scorerIndex = lastEditor
        } else {
            scorerIndex = ((lastPasserIndex - 1) + state.players.count) % state.players.count
        }

        let points = state.wordPoints
        let finalWord = state.wordString
        let scorerName = state.players[scorerIndex].displayName

        state.players[scorerIndex].score += points
        state.log.insert("\(scorerName) scored \(points) for \"\(finalWord)\"", at: 0)

        if state.players[scorerIndex].score >= state.config.winScore {
            state.phase = .gameOver
            state.winnerName = scorerName
            state.clearTurnTimer()
            state.pendingBlindSwap = nil
            roundMessage = "Game over. \(scorerName) wins."
            return
        }

        state.pendingBlindSwap = nil
        state.currentPlayerIndex = scorerIndex
        state.phase = .roundOver
        state.clearTurnTimer()
        roundMessage = "Round over. \(scorerName) scores \(points). Total: \(state.players[scorerIndex].score)"
    }

    func updateLivePreview() {
        guard let state, let mine = myPlayerIndex else {
            livePreviewWord = []
            livePreviewIsValid = nil
            return
        }

        guard pendingTurn.hasDraftEdits else {
            livePreviewWord = []
            livePreviewIsValid = nil
            return
        }

        if let preview = buildDraftPreviewWord(state: state, actorIndex: mine) {
            livePreviewWord = preview
            Task { await computeLivePreviewValidity() }
        } else {
            livePreviewWord = []
            livePreviewIsValid = nil
        }
    }

    func computeLivePreviewValidity() async {
        guard state?.config.mode == .easy else {
            livePreviewIsValid = nil
            return
        }
        guard !livePreviewWord.isEmpty else {
            livePreviewIsValid = nil
            return
        }

        let word = livePreviewWord.map(\.letter).joined()
        livePreviewIsValid = await DictionaryService.isValid(word, mode: .localOnly)
    }
}
