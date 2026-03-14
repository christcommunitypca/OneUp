import SwiftUI

struct WordAreaView: View {
    @EnvironmentObject var engine: GameEngine

    var onTapDefine: ((String) -> Void)? = nil

    private let statusRowHeight: CGFloat = 36
    private let boardStatusInset: CGFloat = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let lookupWord {
                    Button {
                        onTapDefine?(lookupWord)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Define")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(Theme.navy)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Theme.bgSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Theme.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                HStack(spacing: 3) {
                    Text("\(pointsValue)")
                        .font(.system(size: 13, weight: .bold, design: .serif))
                        .monospacedDigit()
                        .foregroundColor(pointsValue > 0 ? Theme.gold : Theme.gray.opacity(0.55))

                    Text(pointsValue == 1 ? "pt" : "pts")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Theme.gray.opacity(pointsValue > 0 ? 1 : 0.7))
                }
                .frame(minWidth: 52)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(pointsValue > 0 ? Theme.goldLight : Theme.bgSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(
                            pointsValue > 0 ? Theme.gold.opacity(0.25) : Theme.border.opacity(0.75),
                            lineWidth: 1
                        )
                )
                .opacity(pointsValue > 0 ? 1 : 0.78)
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

            WordStatusSlotView(status: statusBanner, height: statusRowHeight)
                .padding(.horizontal, boardStatusInset)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private var isOpeningRound: Bool {
        guard let state = engine.state else { return true }
        return state.currentWord.isEmpty
    }

    private var lookupWord: String? {
        guard let state = engine.state else { return nil }
        let word = state.wordString.trimmingCharacters(in: .whitespacesAndNewlines)
        return word.isEmpty ? nil : word
    }

    private var pointsValue: Int {
        if !engine.livePreviewWord.isEmpty {
            return engine.livePreviewWord.enumerated().reduce(0) { partial, item in
                partial + (item.offset < 4 ? 1 : 2)
            }
        }

        guard let state = engine.state, !state.currentWord.isEmpty else { return 0 }
        return state.wordPoints
    }

    private var statusBanner: WordStatusBanner? {
        if let message = engine.roundMessage, !message.isEmpty {
            return .message(message)
        }

        if let message = engine.validationMessage, !message.isEmpty {
            return .message(message)
        }

        guard engine.state?.config.wordHintsEnabled == true else { return nil }
        guard engine.isMyTurn else { return nil }
        guard !engine.livePreviewWord.isEmpty else { return nil }

        if engine.isValidating {
            return .message("Checking word...")
        }

        let previewWord = engine.livePreviewWord.map(\.letter).joined()

        let alreadyPlayed = engine.state?.playedWordsThisRound.contains {
            $0.caseInsensitiveCompare(previewWord) == .orderedSame
        } == true

        if alreadyPlayed {
            return .warning("That word was already played")
        }

        if engine.livePreviewIsValid == true {
            return .validHint("Playable")
        }

        return nil
    }
}

private enum WordStatusBanner {
    case validHint(String)
    case warning(String)
    case message(String)
}

private struct WordStatusSlotView: View {
    let status: WordStatusBanner?
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
            switch status {
            case .validHint(let text):
                WordHintBadgeView(text: text)

            case .warning(let text):
                WordWarningBannerView(message: text)

            case .message(let text):
                WordMessageBannerView(message: text)

            case .none:
                EmptyView()
            }
        
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
    }
}

private struct WordHintBadgeView: View {
    let text: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.sage.opacity(0.9))

            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.sage.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Theme.sageLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Theme.sage.opacity(0.18), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct WordWarningBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 7) {
            Rectangle()
                .fill(Theme.gold)
                .frame(width: 3, height: 16)
                .clipShape(Capsule())

            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.gold)
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Theme.goldLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Theme.gold.opacity(0.22), lineWidth: 1)
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
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
