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
        VStack(alignment: .leading, spacing: 14) {
            SetupSectionTitleView("Online Game")
            TextField("Your display name", text: playerName)
                .font(.system(size: 14)).padding(.horizontal, 10).frame(height: 38)
                .background(SetupFieldFillView()).overlay(SetupFieldStrokeView())
            SetupRulesOptionsView(mode: $mode, timer: $timer, allowBlindSwapAfterTimeout: $allowBlindSwapAfterTimeout,
                                  handSize: $handSize, blindSwapSubtitle: "Applies in online play too.")
            SetupDividerView()
            Button(action: onCreateOnlineGame) {
                HStack {
                    if isCreatingOnlineGame { ProgressView().tint(.white).scaleEffect(0.8) }
                    Text(isCreatingOnlineGame ? "Creating…" : "Create Online Game")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity).frame(height: 42)
                .background(RoundedRectangle(cornerRadius: 6).fill(Theme.navy))
            }.buttonStyle(.plain).disabled(isCreatingOnlineGame)

            HStack(spacing: 8) {
                TextField("Invite code", text: $inviteCode)
                    .textInputAutocapitalization(.characters).autocorrectionDisabled()
                    .font(.system(size: 14, design: .monospaced)).padding(.horizontal, 10).frame(height: 38)
                    .background(SetupFieldFillView()).overlay(SetupFieldStrokeView())
                Button(action: onJoinOnlineGame) {
                    Text("Join").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 14).frame(height: 38)
                        .background(RoundedRectangle(cornerRadius: 6).fill(canJoinOnlineGame ? Theme.sage : Theme.lightGray))
                }.buttonStyle(.plain).disabled(!canJoinOnlineGame)
            }
        }
        .setupCardStyle()
    }
}
