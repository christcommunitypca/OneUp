import SwiftUI

struct SetupSettingsCard: View {
    @Binding var wordHintsEnabled: Bool
    @Binding var defaultCPUDifficulty: CPUDifficulty
    @Binding var timer: TurnTimerOption
    @Binding var handSize: Int
    @Binding var winScore: Int

    let onRulesTapped: () -> Void

    private let numericControlWidth: CGFloat = 96
    private let settingsControlWidth: CGFloat = 96
    private let timerControlWidth: CGFloat = 58
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Game Setup")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .italic()
                    .foregroundColor(Theme.navy)

                Spacer()

                NavigationLink {
                    SupportView()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11, weight: .semibold))

                        Text("Support")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Theme.navy)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Theme.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button(action: onRulesTapped) {
                    HStack(spacing: 4) {
                        Image(systemName: "book")
                            .font(.system(size: 12))

                        Text("Rules")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Theme.navy)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Theme.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            toggleRow(title: "Word Hints", isOn: $wordHintsEnabled)

            SetupDividerView()

            pickerRow(title: "Turn Timer", selectionText: timer.displayName) {
                Picker("Timer", selection: $timer) {
                    ForEach(TurnTimerOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
            }

            SetupDividerView()

            stepperRow(title: "Cards in Hand", value: handSize) {
                handSize = max(3, handSize - 1)
            } onPlus: {
                handSize = min(12, handSize + 1)
            }

            SetupDividerView()

            stepperRow(title: "Winning Score", value: winScore) {
                winScore = max(5, winScore - 5)
            } onPlus: {
                winScore = min(100, winScore + 5)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.border, lineWidth: 1)
        )
        .shadow(color: Theme.cardShadow, radius: 3, y: 1)
    }

    private func pickerRow<Content: View>(
        title: String,
        selectionText: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            Menu {
                content()
            } label: {
                HStack(spacing: 4) {
                    Spacer(minLength: 0)

                    Text(selectionText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.navy)
                        .multilineTextAlignment(.trailing)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Theme.navy)
                }
                .padding(.horizontal, 8)
                .frame(width: timerControlWidth, height: 28, alignment: .trailing)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Theme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            HStack {
                Spacer()
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(Theme.navy)
            }
            .frame(width: numericControlWidth, alignment: .trailing)
        }
    }

    private func stepperRow(
        title: String,
        value: Int,
        onMinus: @escaping () -> Void,
        onPlus: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            HStack(spacing: 8) {
                Button(action: onMinus) {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.navy)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Theme.navyLight))
                }
                .buttonStyle(.plain)

                Text("\(value)")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(Theme.navy)
                    .frame(minWidth: 24)

                Button(action: onPlus) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.navy)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Theme.navyLight))
                }
                .buttonStyle(.plain)
            }
            .frame(width: numericControlWidth, alignment: .trailing)
        }
    }
}
