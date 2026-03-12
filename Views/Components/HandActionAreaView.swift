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

    private let actionAreaHeight: CGFloat = 91

    var body: some View {
        Group {
            if isMyTurn {
                VStack(spacing: 7) {
                    HStack(spacing: 7) {
                        HandPrimaryButton(
                            title: isValidating ? "Checking…" : playButtonTitle,
                            disabled: !canChoosePlay || isValidating,
                            action: onPlay
                        )
                        HandSecondaryButton(title: "Discard", disabled: !canChooseDiscard, action: onDiscard)
                    }
                    HStack(spacing: 7) {
                        HandSecondaryButton(title: "Pass", action: onPass)
                        HandSecondaryButton(title: "Clear", action: onClear)
                    }
                }
                .frame(height: actionAreaHeight)
            } else {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Theme.bgSurface)
                    .overlay(
                        Text("Waiting for opponent")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Theme.gray)
                    )
                    .frame(height: actionAreaHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: actionAreaHeight)
    }
}

private struct HandPrimaryButton: View {
    let title: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(disabled ? Theme.gray : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(disabled ? Theme.lightGray : Theme.navy)
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

private struct HandSecondaryButton: View {
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
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(disabled ? Theme.gray : Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Theme.borderBold, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}
