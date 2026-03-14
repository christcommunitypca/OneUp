import Foundation

@MainActor
extension GameEngine {
    func updateLivePreview() {
        previewValidationTask?.cancel()

        guard let state else {
            livePreviewWord = []
            livePreviewIsValid = nil
            livePreviewAlreadyPlayed = false
            refreshCoachTip()
            return
        }

        guard pendingTurn.hasDraftEdits else {
            livePreviewWord = []
            livePreviewIsValid = nil
            livePreviewAlreadyPlayed = false
            refreshCoachTip()
            return
        }

        let preview = buildDraftPreviewWord(from: state)
        livePreviewWord = preview

        let word = preview.map(\.letter).joined()
        livePreviewAlreadyPlayed = !word.isEmpty && word != state.wordString && state.playedWordsThisRound.contains(word)

        guard !livePreviewAlreadyPlayed else {
            livePreviewIsValid = nil
            refreshCoachTip()
            return
        }

        guard state.config.wordHintsEnabled, !preview.isEmpty else {
            livePreviewIsValid = nil
            refreshCoachTip()
            return
        }

        livePreviewIsValid = nil
        refreshCoachTip()

        previewValidationTask = Task { [weak self] in
            let isValid = await DictionaryService.isValid(
                word,
                validationMode: .localOnly
            )

            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard let self else { return }
                let currentPreviewWord = self.livePreviewWord.map(\.letter).joined()
                guard currentPreviewWord == word else { return }
                self.livePreviewIsValid = isValid
                self.refreshCoachTip()
            }
        }
    }
}
