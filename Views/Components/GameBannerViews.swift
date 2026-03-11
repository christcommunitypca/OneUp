//
//  GameBannerViews.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct CompactStatusView: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "92400E"))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(hex: "FEF3C7"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(hex: "FCD34D"), lineWidth: 1)
        )
    }
}

struct WinnerBannerView: View {
    let winner: String
    let score: Int
    let onNewGame: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Winner")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white.opacity(0.78))

            Text(winner)
                .font(.system(size: 28, weight: .black, design: .serif))
                .italic()
                .foregroundColor(.white)

            Text("\(score) points")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.88))

            HStack(spacing: 8) {
                InverseBannerButton(title: "New Game", action: onNewGame)
                InverseBannerButton(title: "Settings", action: onSettings)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: "6E4DD8"))
        )
    }
}

struct BlindSwapBannerView: View {
    let timedOutPlayerName: String
    let onBlindSwap: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Blind swap available")
                .font(.system(size: 18, weight: .black, design: .serif))
                .italic()
                .foregroundColor(Color(hex: "6E4DD8"))

            Text("\(timedOutPlayerName) ran out of time. You may make one random swap, or skip it.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "4B5563"))

            HStack(spacing: 8) {
                Button(action: onBlindSwap) {
                    Text("Blind Swap")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "6E4DD8"))
                        )
                }
                .buttonStyle(.plain)

                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
        )
    }
}

private struct InverseBannerButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: "111827"))
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.white)
                )
        }
        .buttonStyle(.plain)
    }
}
