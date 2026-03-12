//
//  HandActionAreaView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct HandActionAreaView: View {
    let isMyTurn: Bool
    let isValidating: Bool
    let playButtonTitle: String
    let playIsDiscard: Bool
    let canChoosePlay: Bool
    let canChooseSwap: Bool
    let canChooseDiscard: Bool
    let swapIsActive: Bool
    let onPlay: () -> Void
    let onSwap: () -> Void
    let onDiscard: () -> Void
    let onPass: () -> Void
    let onClear: () -> Void

    var body: some View {
        Group {
            if isMyTurn {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        WordBuilderPrimaryButton(
                            title: isValidating ? "Checking..." : playButtonTitle,
                            color: Color(hex: "6E4DD8"),
                            disabled: !canChoosePlay || isValidating,
                            action: onPlay
                        )

                        WordBuilderSecondaryButton(
                            title: "Discard",
                            disabled: !canChooseDiscard,
                            action: onDiscard
                        )
                    }

                    HStack(spacing: 8) {
                        WordBuilderSecondaryButton(
                            title: "Pass",
                            action: onPass
                        )

                        WordBuilderSecondaryButton(
                            title: "Clear",
                            action: onClear
                        )
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(hex: "F9FAFB"))
                    .overlay(
                        Text("Waiting on Opponent")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "6B7280"))
                    )
            }
        }
        .frame(minHeight: 96)
    }
}

private struct WordBuilderPrimaryButton: View {
    let title: String
    let color: Color
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(disabled ? Color(hex: "D1D5DB") : color)
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

private struct WordBuilderSecondaryButton: View {
    let title: String
    let disabled: Bool
    let action: () -> Void

    init(title: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.disabled = disabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(disabled ? Color(hex: "9CA3AF") : Color(hex: "111827"))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}
