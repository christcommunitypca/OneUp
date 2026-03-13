import SwiftUI

struct SetupView: View {
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss

    @State private var cpuPlayers: [CPUSetup] = [
        CPUSetup(name: "Kate", difficulty: .adept)
    ]
    @State private var defaultCPUDifficulty: CPUDifficulty = .adept
    @State private var wordHintsEnabled: Bool = true
    @State private var timer: TurnTimerOption = .off
    @State private var handSize: Int = 7
    @State private var winScore: Int = 20
    @State private var showRules = false

    private let maxPlayers = 10
    private let botNames = ["Kate", "Claire", "Henry", "Jack", "Sims", "Miles", "Luke", "Charlotte", "Peggy"]

    private var canAddCPU: Bool {
        (1 + cpuPlayers.count) < maxPlayers
    }

    var body: some View {
        ZStack {
            Theme.bgPage.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(spacing: 4) {
                        Text("One Up")
                            .font(.system(size: 30, weight: .bold, design: .serif))
                            .italic()
                            .foregroundColor(Theme.navy)
                            .frame(maxWidth: .infinity)

                        Text("Add a letter. Steal the lead.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Theme.gray)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 10)

                    SetupSettingsCard(
                        wordHintsEnabled: $wordHintsEnabled,
                        defaultCPUDifficulty: $defaultCPUDifficulty,
                        timer: $timer,
                        handSize: $handSize,
                        winScore: $winScore,
                        onRulesTapped: { showRules = true }
                    )

                    SetupLineupCard(
                        cpuPlayers: $cpuPlayers,
                        canAddCPU: canAddCPU,
                        onAddCPU: addCPU,
                        onRemoveCPU: removeCPU
                    )

                    Color.clear.frame(height: 88)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SetupBottomBar(onStartGame: startLocalGame)
        }
        .sheet(isPresented: $showRules) {
            SetupRulesSheet(
                isPresented: $showRules,
                winScore: winScore
            )
        }
    }

    private func addCPU() {
        guard canAddCPU else { return }
        cpuPlayers.append(CPUSetup(name: nextBotName(), difficulty: defaultCPUDifficulty))
    }

    private func removeCPU(_ id: UUID) {
        cpuPlayers.removeAll { $0.id == id }
    }

    private func nextBotName() -> String {
        let usedNames = Set(cpuPlayers.map(\.name))
        if let unused = botNames.first(where: { !usedNames.contains($0) }) {
            return unused
        }
        return botNames[cpuPlayers.count % botNames.count]
    }

    private func startLocalGame() {
        let config = GameConfig(
            wordHintsEnabled: wordHintsEnabled,
            defaultCPUDifficulty: defaultCPUDifficulty,
            timer: timer,
            handSize: handSize,
            winScore: winScore
        )

        engine.newLocalGame(playerNames: ["Me"], cpuPlayers: cpuPlayers, config: config, humanClerkId: nil)

        dismiss()
    }
}
