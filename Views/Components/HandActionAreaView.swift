//
//  HandActionAreaView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct HandActionAreaView: View {
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
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                WordBuilderPrimaryButton(
                    title: isValidating ? "Checking..." : playButtonTitle,
                    color: playIsDiscard ? Color(hex: "C2410C") : Color(hex: "6E4DD8"),
                    disabled: !canChoosePlay || isValidating,
                    action: onPlay
                )

                WordBuilderModeButton(
                    title: "Swap",
                    isActive: swapIsActive,
                    disabled: !canChooseSwap,
                    action: onSwap
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

private struct WordBuilderModeButton: View {
    let title: String
    let isActive: Bool
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(
                    disabled ? Color(hex: "9CA3AF") :
                    isActive ? Color(hex: "6E4DD8") :
                    Color(hex: "111827")
                )
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isActive ? Color(hex: "F5F3FF") : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(
                            isActive ? Color(hex: "6E4DD8") : Color(hex: "D1D5DB"),
                            lineWidth: isActive ? 2 : 1
                        )
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
