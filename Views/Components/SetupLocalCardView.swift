//
//  SetupLocalCardView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct SetupLocalCardView: View {
    @Binding var playerNames: [String]
    @Binding var cpuCount: Int
    @Binding var mode: GameMode
    @Binding var timer: TurnTimerOption
    @Binding var allowBlindSwapAfterTimeout: Bool
    @Binding var handSize: Int

    let maxPlayers: Int
    let onAddHuman: () -> Void
    let onRemoveHuman: (Int) -> Void
    let bindingForPlayerName: (Int) -> Binding<String>
    let cpuNamesPreview: (Int) -> [String]

    private var totalPlayerCount: Int {
        playerNames.count + cpuCount
    }

    private var canAddHumanPlayer: Bool {
        totalPlayerCount < maxPlayers && playerNames.count < maxPlayers
    }

    private var maxAllowedCPUCount: Int {
        max(0, maxPlayers - playerNames.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SetupSectionTitleView("Players")

            VStack(spacing: 8) {
                ForEach(playerNames.indices, id: \.self) { index in
                    HStack(spacing: 8) {
                        Text(index == 0 ? "You" : "P\(index + 1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "6B7280"))
                            .frame(width: 38, alignment: .leading)

                        TextField(index == 0 ? "Your name" : "Player name", text: bindingForPlayerName(index))
                            .padding(.horizontal, 12)
                            .frame(height: 42)
                            .background(SetupFieldFillView())
                            .overlay(SetupFieldStrokeView())

                        if index > 0 {
                            Button {
                                onRemoveHuman(index)
                            } label: {
                                Text("Remove")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "C2410C"))
                                    .padding(.horizontal, 10)
                                    .frame(height: 38)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color(hex: "FFF7ED"))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(Color(hex: "FED7AA"), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if canAddHumanPlayer {
                    Button(action: onAddHuman) {
                        Text("Add Human")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "6E4DD8"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(hex: "F5F3FF"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color(hex: "DDD6FE"), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            SetupDividerView()

            SetupSectionTitleView("Computer Players")

            Stepper(value: $cpuCount, in: 0...maxAllowedCPUCount) {
                HStack {
                    Text("CPU Opponents")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))
                    Spacer()
                    Text("\(cpuCount)")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(Color(hex: "6E4DD8"))
                }
            }
            .tint(Color(hex: "6E4DD8"))

            SetupCPUPreviewView(names: cpuNamesPreview(cpuCount))

            SetupDividerView()

            SetupSectionTitleView("Rules")

            SetupRulesOptionsView(
                mode: $mode,
                timer: $timer,
                allowBlindSwapAfterTimeout: $allowBlindSwapAfterTimeout,
                handSize: $handSize,
                blindSwapSubtitle: "The next player may choose a random swap after a timeout."
            )
        }
        .setupCardStyle()
    }
}
