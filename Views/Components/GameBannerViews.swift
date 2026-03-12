import SwiftUI

struct CompactStatusView: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.gold)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Theme.goldLight))
        .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Theme.gold.opacity(0.30), lineWidth: 1))
    }
}

struct WinnerBannerView: View {
    let winner: String
    let score: Int
    let onNewGame: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Winner")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.70))
                .textCase(.uppercase).kerning(0.8)

            Text(winner)
                .font(.system(size: 26, weight: .bold, design: .serif))
                .italic()
                .foregroundColor(.white)

            Text("\(score) points")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.white.opacity(0.85))

            HStack(spacing: 8) {
                InverseBannerButton(title: "New Game", action: onNewGame)
                InverseBannerButton(title: "Settings", action: onSettings)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.navy)
        )
    }
}

struct BlindSwapBannerView: View {
    let timedOutPlayerName: String
    let onBlindSwap: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Blind swap available")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .italic()
                .foregroundColor(Theme.navy)

            Text("\(timedOutPlayerName) ran out of time. You may make one random swap, or skip it.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Theme.textSecondary)

            HStack(spacing: 8) {
                Button(action: onBlindSwap) {
                    Text("Blind Swap")
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.navy))
                }.buttonStyle(.plain)

                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(size: 13, weight: .regular)).foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Theme.borderBold, lineWidth: 1))
                }.buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Theme.border, lineWidth: 1))
    }
}

private struct InverseBannerButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.navy)
                .padding(.horizontal, 10).frame(height: 30)
                .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.white))
        }.buttonStyle(.plain)
    }
}
