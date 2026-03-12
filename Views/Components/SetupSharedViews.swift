//
//  SetupSharedViews.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct SetupRulesOptionsView: View {
    @Binding var mode: GameMode
    @Binding var timer: TurnTimerOption
    @Binding var allowBlindSwapAfterTimeout: Bool
    @Binding var handSize: Int

    let blindSwapSubtitle: String

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dictionary Help")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))
                    Text("Easy shows live feedback.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "6B7280"))
                }

                Spacer()

                Picker("Mode", selection: $mode) {
                    ForEach(GameMode.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 170)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Turn Timer")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))
                    Text("Set the turn limit.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "6B7280"))
                }

                Spacer()

                Picker("Turn Timer", selection: $timer) {
                    ForEach(TurnTimerOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color(hex: "6E4DD8"))
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hand Size")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))
                    Text("Choose how many cards each player holds.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "6B7280"))
                }

                Spacer()

                HStack(spacing: 10) {
                    Text("\(handSize)")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(Color(hex: "6E4DD8"))
                        .frame(minWidth: 24)

                    Stepper("", value: $handSize, in: 5...10)
                        .labelsHidden()
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Toggle(isOn: $allowBlindSwapAfterTimeout) {
                    Text("Blind Swap After Timeout")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))
                }
                .tint(Color(hex: "6E4DD8"))

                Text(blindSwapSubtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "6B7280"))
            }
        }
    }
}

struct SetupCPUPreviewView: View {
    let names: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CPU names")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "6B7280"))

            if names.isEmpty {
                Text("No CPU opponents")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "6B7280"))
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
                    ForEach(names, id: \.self) { name in
                        Text(name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "111827"))
                            .padding(.horizontal, 10)
                            .frame(height: 32)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(hex: "FAFAF9"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
}

struct SetupSectionTitleView: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 17, weight: .black, design: .serif))
            .italic()
            .foregroundColor(Color(hex: "6E4DD8"))
    }
}

struct SetupSummaryLineView: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(Color(hex: "6E4DD8"))
                .frame(width: 4, height: 4)
                .padding(.top, 7)

            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            Spacer()
        }
    }
}

struct SetupFieldFillView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.white)
    }
}

struct SetupFieldStrokeView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
    }
}

struct SetupDividerView: View {
    var body: some View {
        Rectangle()
            .fill(Color(hex: "E5E7EB"))
            .frame(height: 1)
    }
}

extension View {
    func setupCardStyle() -> some View {
        self
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
            )
    }
}
