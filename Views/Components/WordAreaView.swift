import SwiftUI

struct WordAreaView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WordAreaHeaderView(
                statusTitle: statusTitle,
                statusSubtitle: statusSubtitle,
                displayedPoints: displayedPoints
            )

            WordBoardSurfaceView(
                isOpeningRound: isOpeningRound,
                livePreviewWord: engine.livePreviewWord,
                currentWord: engine.state?.currentWord ?? [],
                isMyTurn: engine.isMyTurn,
                pendingTurn: engine.pendingTurn,
                onChooseInsertPosition: { position in
                    engine.chooseInsertPosition(position)
                },
                onChooseSwapIndex: { index in
                    engine.chooseWordIndexForSwap(index)
                }
            )

            if let message = engine.roundMessage, !message.isEmpty {
                WordMessageBannerView(message: message)
            } else if let message = engine.validationMessage, !message.isEmpty {
                WordMessageBannerView(message: message)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
        )
    }

    private var isOpeningRound: Bool {
        guard let state = engine.state else { return true }
        return state.currentWord.isEmpty
    }

    private var statusTitle: String {
        if let state = engine.state, state.currentWord.isEmpty {
            return "Start the round"
        }
        if engine.pendingTurn.action == .discard {
            return "Discard selected cards"
        }
        if engine.pendingTurn.action == .swap, engine.pendingTurn.activeHandIndex != nil {
            return "Choose a letter to swap"
        }
        if engine.pendingTurn.hasDraftEdits {
            return "Preview"
        }
        return "Board"
    }

    private var statusSubtitle: String {
        if let state = engine.state, state.currentWord.isEmpty {
            return "Tap letters in the order you want them played."
        }
        if engine.pendingTurn.action == .discard {
            return "Select the cards you want to throw away."
        }
        if engine.pendingTurn.action == .swap, engine.pendingTurn.activeHandIndex != nil {
            return "Tap a board letter to replace it."
        }
        if engine.pendingTurn.activeHandIndex != nil {
            return "Tap a gap to place the active card."
        }
        if engine.pendingTurn.hasDraftEdits {
            return "Add more edits or press Play."
        }
        return "Select a card to begin your turn."
    }

    private var displayedPoints: Int? {
        if !engine.livePreviewWord.isEmpty {
            return engine.livePreviewWord.enumerated().reduce(0) { partial, entry in
                partial + (entry.offset < 4 ? 1 : 2)
            }
        }

        guard let state = engine.state, !state.currentWord.isEmpty else { return nil }
        return state.wordPoints
    }
}
