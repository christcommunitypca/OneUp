import Foundation

@MainActor
extension GameEngine {
    func updateLivePreview() {
        previewValidationTask?.cancel()

        guard let state else {
            livePreviewWord = []
            livePreviewIsValid = nil
            return
        }

        guard pendingTurn.hasDraftEdits else {
            livePreviewWord = []
            livePreviewIsValid = nil
            return
        }

        let preview = buildDraftPreviewWord(from: state)
        livePreviewWord = preview

        guard state.config.wordHintsEnabled, !preview.isEmpty else {
            livePreviewIsValid = nil
            return
        }

        let word = preview.map(\.letter).joined()
        livePreviewIsValid = nil

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
            }
        }
    }
}
