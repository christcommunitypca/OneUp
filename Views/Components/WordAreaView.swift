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
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Theme.goldLight))
                    .overlay(RoundedRectangle(cornerRadius: 4, style: .continuous).stroke(Theme.gold.opacity(0.25), lineWidth: 1))
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
}

struct WordAreaHeaderView: View {
    let statusTitle: String
    let statusSubtitle: String
    let displayedPoints: Int?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .italic().foregroundColor(Theme.navy)
                Text(statusSubtitle)
                    .font(.system(size: 11, weight: .regular)).foregroundColor(Theme.gray)
            }
            Spacer()
            if let points = displayedPoints {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(points)").font(.system(size: 16, weight: .bold, design: .serif)).foregroundColor(Theme.gold)
                    Text(points == 1 ? "point" : "points").font(.system(size: 9, weight: .regular)).foregroundColor(Theme.gray)
                }
                .padding(.horizontal, 8).padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Theme.goldLight))
            }
        }
    }
}

struct WordMessageBannerView: View {
    let message: String

    var body: some View {
        let isError = message.localizedCaseInsensitiveContains("not") ||
            message.localizedCaseInsensitiveContains("could not") ||
            message.localizedCaseInsensitiveContains("select") ||
            message.localizedCaseInsensitiveContains("clear")

        return HStack(spacing: 7) {
            Rectangle()
                .fill(isError ? Theme.crimson : Theme.sage)
                .frame(width: 3, height: 16)
                .clipShape(Capsule())

            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isError ? Theme.crimson : Theme.sage)
            Spacer()
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(isError ? Theme.crimsonLight : Theme.sageLight))
        .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous)
            .stroke(isError ? Theme.crimson.opacity(0.20) : Theme.sage.opacity(0.20), lineWidth: 1))
    }
}
