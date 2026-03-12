import SwiftUI

struct WordAreaView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()

                if let displayedPoints {
                    Text("Points: \(displayedPoints)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "6E4DD8"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color(hex: "F5F3FF"))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color(hex: "DDD6FE"), lineWidth: 1)
                        )
                }
            }

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
        .padding(10)
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
