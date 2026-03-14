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
    
    private let lastLineupKey = "last_cpu_lineup"
    private let lastDefaultBotSkillKey = "last_default_bot_skill"
    
    private var canAddCPU: Bool {
        (1 + cpuPlayers.count) < maxPlayers
    }

    var body: some View {
        ZStack {
            Theme.bgPage.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.navyLight)
                                    .frame(width: 64, height: 64)

                                Image(systemName: "textformat.abc.dottedunderline")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Theme.navy)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("One Up")
                                    .font(.system(size: 32, weight: .bold, design: .serif))
                                    .italic()
                                    .foregroundColor(Theme.navy)

                                Text("Add a letter. Steal the lead.")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)
                            }

                            Spacer()
                        }

                        Text("Build the next word, outplay the table, and race to the winning score.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.border, lineWidth: 1)
                    )
                    .shadow(color: Theme.cardShadow, radius: 3, y: 1)
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
                        defaultCPUDifficulty: $defaultCPUDifficulty,
                        canAddCPU: canAddCPU,
                        onAddCPU: addCPU,
                        onRemoveCPU: removeCPU,
                        onReuseLastLineup: loadLastLineup
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

    private func saveLastLineup() {
        if let data = try? JSONEncoder().encode(cpuPlayers) {
            UserDefaults.standard.set(data, forKey: lastLineupKey)
        }
        UserDefaults.standard.set(defaultCPUDifficulty.rawValue, forKey: lastDefaultBotSkillKey)
    }

    private func loadLastLineup() {
        if let rawValue = UserDefaults.standard.string(forKey: lastDefaultBotSkillKey),
           let savedDifficulty = CPUDifficulty(rawValue: rawValue) {
            defaultCPUDifficulty = savedDifficulty
        }

        guard let data = UserDefaults.standard.data(forKey: lastLineupKey),
              let savedLineup = try? JSONDecoder().decode([CPUSetup].self, from: data) else {
            return
        }

        cpuPlayers = savedLineup
    }
    
    private func startLocalGame() {
        let config = GameConfig(
            wordHintsEnabled: wordHintsEnabled,
            defaultCPUDifficulty: defaultCPUDifficulty,
            timer: timer,
            handSize: handSize,
            winScore: winScore
        )
        saveLastLineup()
        engine.newLocalGame(playerNames: ["Me"], cpuPlayers: cpuPlayers, config: config, humanClerkId: nil)

        dismiss()
    }
}
