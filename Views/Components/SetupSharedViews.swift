import SwiftUI

struct SetupRulesOptionsView: View {
    @Binding var mode: GameMode
    @Binding var timer: TurnTimerOption
    @Binding var allowBlindSwapAfterTimeout: Bool
    @Binding var handSize: Int
    let blindSwapSubtitle: String

    var body: some View {
        VStack(spacing: 12) {
            optionRow(title: "Dictionary Help", subtitle: "Easy shows live feedback.") {
                Picker("Mode", selection: $mode) {
                    ForEach(GameMode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented).frame(width: 160)
            }

            Divider().background(Theme.border)

            optionRow(title: "Turn Timer", subtitle: "Set the time limit per turn.") {
                Picker("Timer", selection: $timer) {
                    ForEach(TurnTimerOption.allCases) { Text($0.displayName).tag($0) }
                }
                .pickerStyle(.menu).tint(Theme.navy)
            }

            Divider().background(Theme.border)

            optionRow(title: "Hand Size", subtitle: "Cards each player holds.") {
                HStack(spacing: 8) {
                    Text("\(handSize)")
                        .font(.system(size: 15, weight: .bold, design: .serif)).foregroundColor(Theme.navy).frame(minWidth: 22)
                    Stepper("", value: $handSize, in: 5...10).labelsHidden()
                }
            }

            Divider().background(Theme.border)

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blind Swap After Timeout")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(Theme.text)
                    Text(blindSwapSubtitle)
                        .font(.system(size: 11, weight: .regular)).foregroundColor(Theme.gray)
                }
                Spacer()
                Toggle("", isOn: $allowBlindSwapAfterTimeout).labelsHidden().tint(Theme.navy)
            }
        }
    }

    private func optionRow<Content: View>(title: String, subtitle: String, @ViewBuilder control: () -> Content) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .medium)).foregroundColor(Theme.text)
                Text(subtitle).font(.system(size: 11, weight: .regular)).foregroundColor(Theme.gray)
            }
            Spacer()
            control()
        }
    }
}

struct SetupCPUPreviewView: View {
    let names: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CPU Players").font(.system(size: 11, weight: .medium)).foregroundColor(Theme.gray).textCase(.uppercase).kerning(0.5)
            if names.isEmpty {
                Text("None added").font(.system(size: 12, weight: .regular)).foregroundColor(Theme.gray)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 6)], spacing: 6) {
                    ForEach(names, id: \.self) { name in
                        Text(name)
                            .font(.system(size: 12, weight: .medium)).foregroundColor(Theme.textSecondary)
                            .padding(.horizontal, 8).frame(height: 28).frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Theme.bgSurface))
                            .overlay(RoundedRectangle(cornerRadius: 4, style: .continuous).stroke(Theme.border, lineWidth: 1))
                    }
                }
            }
        }
    }
}

struct SetupSectionTitleView: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .serif))
            .italic().foregroundColor(Theme.navy)
    }
}

struct SetupSummaryLineView: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("–").font(.system(size: 12)).foregroundColor(Theme.navy).padding(.top, 1)
            Text(text).font(.system(size: 12, weight: .regular)).foregroundColor(Theme.textSecondary)
            Spacer()
        }
    }
}

struct SetupFieldFillView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.white)
    }
}

struct SetupFieldStrokeView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Theme.borderBold, lineWidth: 1)
    }
}

struct SetupDividerView: View {
    var body: some View {
        Rectangle().fill(Theme.border).frame(height: 1)
    }
}

extension View {
    func setupCardStyle() -> some View {
        self
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Theme.border, lineWidth: 1))
            .shadow(color: Theme.cardShadow, radius: 3, y: 1)
    }
}
