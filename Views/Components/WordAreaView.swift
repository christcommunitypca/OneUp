import SwiftUI

struct WordAreaView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                if let pts = displayedPoints {
                    HStack(spacing: 3) {
                        Text("\(pts)")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundColor(Theme.gold)
                        Text(pts == 1 ? "pt" : "pts")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Theme.gray)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Theme.goldLight)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Theme.gold.opacity(0.25), lineWidth: 1)
                    )
                }
            }

            WordBoardSurfaceView(
                isOpeningRound: isOpeningRound,
                livePreviewWord: engine.livePreviewWord,
                currentWord: engine.state?.currentWord ?? [],
                isMyTurn: engine.isMyTurn,
                pendingTurn: engine.pendingTurn,
                onChooseInsertPosition: { engine.chooseInsertPosition($0) },
                onChooseSwapIndex: { engine.chooseWordIndexForSwap($0) }
            )

            if let hint = liveHint {
                WordHintBannerView(text: hint.text, isValid: hint.isValid)
            }

            if let message = engine.roundMessage, !message.isEmpty {
                WordMessageBannerView(message: message)
            } else if let message = engine.validationMessage, !message.isEmpty {
                WordMessageBannerView(message: message)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Theme.border, lineWidth: 1))
    }

    private var isOpeningRound: Bool {
        guard let state = engine.state else { return true }
        return state.currentWord.isEmpty
    }

    private var displayedPoints: Int? {
        if !engine.livePreviewWord.isEmpty {
            return engine.livePreviewWord.enumerated().reduce(0) { $0 + ($1.offset < 4 ? 1 : 2) }
        }
        guard let state = engine.state, !state.currentWord.isEmpty else { return nil }
        return state.wordPoints
    }

    private var liveHint: (text: String, isValid: Bool)? {
        guard engine.state?.config.wordHintsEnabled == true else { return nil }
        guard engine.isMyTurn else { return nil }
        guard !engine.livePreviewWord.isEmpty else { return nil }

        if let isValid = engine.livePreviewIsValid {
            return (isValid ? "Valid word" : "Not a valid word", isValid)
        }

        return ("Checking word...", true)
    }
}

private struct WordHintBannerView: View {
    let text: String
    let isValid: Bool

    var body: some View {
        HStack(spacing: 7) {
            Rectangle()
                .fill(isValid ? Theme.sage : Theme.crimson)
                .frame(width: 3, height: 16)
                .clipShape(Capsule())

            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isValid ? Theme.sage : Theme.crimson)

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(isValid ? Theme.sageLight : Theme.crimsonLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(
                    isValid ? Theme.sage.opacity(0.20) : Theme.crimson.opacity(0.20),
                    lineWidth: 1
                )
        )
    }
}

private struct WordMessageBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 7) {
            Rectangle()
                .fill(Theme.navy)
                .frame(width: 3, height: 16)
                .clipShape(Capsule())

            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Theme.bgSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}
