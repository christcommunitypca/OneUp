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

    private var totalPlayerCount: Int { playerNames.count + cpuCount }
    private var canAddHumanPlayer: Bool { totalPlayerCount < maxPlayers }
    private var maxAllowedCPUCount: Int { max(0, maxPlayers - playerNames.count) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SetupSectionTitleView("Players")
            VStack(spacing: 6) {
                ForEach(playerNames.indices, id: \.self) { i in
                    HStack(spacing: 8) {
                        Text(i == 0 ? "You" : "P\(i+1)")
                            .font(.system(size: 12, weight: .medium)).foregroundColor(Theme.gray).frame(width: 32, alignment: .leading)
                        TextField(i == 0 ? "Your name" : "Player name", text: bindingForPlayerName(i))
                            .font(.system(size: 14)).padding(.horizontal, 10).frame(height: 38)
                            .background(SetupFieldFillView()).overlay(SetupFieldStrokeView())
                        if i > 0 {
                            Button { onRemoveHuman(i) } label: {
                                Text("Remove").font(.system(size: 11, weight: .medium)).foregroundColor(Theme.crimson)
                                    .padding(.horizontal, 8).frame(height: 34)
                                    .background(RoundedRectangle(cornerRadius: 5).fill(Theme.crimsonLight))
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Theme.crimson.opacity(0.25), lineWidth: 1))
                            }.buttonStyle(.plain)
                        }
                    }
                }
                if canAddHumanPlayer {
                    Button(action: onAddHuman) {
                        Text("+ Add Human Player")
                            .font(.system(size: 12, weight: .medium)).foregroundColor(Theme.navy)
                            .frame(maxWidth: .infinity).frame(height: 36)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Theme.navyLight))
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Theme.navy.opacity(0.25), lineWidth: 1))
                    }.buttonStyle(.plain)
                }
            }
            SetupDividerView()
            HStack {
                SetupSectionTitleView("CPU Opponents")
                Spacer()
                Stepper(value: $cpuCount, in: 0...maxAllowedCPUCount) {
                    Text("\(cpuCount)").font(.system(size: 15, weight: .bold, design: .serif)).foregroundColor(Theme.navy).frame(minWidth: 20)
                }.tint(Theme.navy)
            }
            SetupCPUPreviewView(names: cpuNamesPreview(cpuCount))
            SetupDividerView()
            SetupSectionTitleView("Rules")
            SetupRulesOptionsView(mode: $mode, timer: $timer, allowBlindSwapAfterTimeout: $allowBlindSwapAfterTimeout,
                                  handSize: $handSize, blindSwapSubtitle: "Next player may make one random swap after a timeout.")
        }
        .setupCardStyle()
    }
}
