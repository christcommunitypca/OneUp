//
//  SetupOnlineCardView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct SetupOnlineCardView: View {
    let playerName: Binding<String>

    @Binding var inviteCode: String
    @Binding var isCreatingOnlineGame: Bool
    @Binding var mode: GameMode
    @Binding var timer: TurnTimerOption
    @Binding var allowBlindSwapAfterTimeout: Bool
    @Binding var handSize: Int

    let canJoinOnlineGame: Bool
    let onCreateOnlineGame: () -> Void
    let onJoinOnlineGame: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SetupSectionTitleView("Online Game")

            TextField("Your display name", text: playerName)
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(SetupFieldFillView())
                .overlay(SetupFieldStrokeView())

            SetupRulesOptionsView(
                mode: $mode,
                timer: $timer,
                allowBlindSwapAfterTimeout: $allowBlindSwapAfterTimeout,
                handSize: $handSize,
                blindSwapSubtitle: "Applies in online play too."
            )

            SetupDividerView()

            Button(action: onCreateOnlineGame) {
                HStack {
                    if isCreatingOnlineGame {
                        ProgressView().tint(.white)
                    }
                    Text(isCreatingOnlineGame ? "Creating..." : "Create Online Game")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "6E4DD8"))
                )
            }
            .buttonStyle(.plain)
            .disabled(isCreatingOnlineGame)

            HStack(spacing: 8) {
                TextField("Invite code", text: $inviteCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .frame(height: 42)
                    .background(SetupFieldFillView())
                    .overlay(SetupFieldStrokeView())

                Button(action: onJoinOnlineGame) {
                    Text("Join")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(canJoinOnlineGame ? Color(hex: "059669") : Color(hex: "D1D5DB"))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canJoinOnlineGame)
            }
        }
        .setupCardStyle()
    }
}
