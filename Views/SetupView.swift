import SwiftUI
import Foundation

struct SetupView: View {
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss

    @State private var cpuPlayers: [CPUSetup] = [
        CPUSetup(name: "Kate", difficulty: .pro)
    ]
    @State private var defaultCPUDifficulty: CPUDifficulty = .pro
    @State private var wordHintsEnabled: Bool = true
    @State private var timer: TurnTimerOption = .off
    @State private var handSize: Int = 7
    @State private var winScore: Int = 20
    @State private var showRules = false

    private let lastDefaultBotSkillKey = "last_default_bot_skill"
    private let maxPlayers = 10
    private let botNames = ["Kate", "Claire", "Henry", "Jack", "Sims", "Miles", "Luke", "Charlotte", "Peggy"]

    private let lastSetupKey = "last_setup_snapshot"
    private let legacyLineupKey = "last_cpu_lineup"
    private let legacyDefaultBotSkillKey = "last_default_bot_skill"

    private struct LastSetupSnapshot: Codable {
        let cpuPlayers: [CPUSetup]
        let defaultCPUDifficulty: CPUDifficulty
        let wordHintsEnabled: Bool
        let timer: TurnTimerOption
        let handSize: Int
        let winScore: Int
    }

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
                            SetupHeaderMarkView()

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
        .onAppear(perform: loadLastSetupIfAvailable)
        .onChange(of: cpuPlayers) { persistCurrentSetup() }
        .onChange(of: defaultCPUDifficulty) { persistCurrentSetup() }
        .onChange(of: wordHintsEnabled) { persistCurrentSetup() }
        .onChange(of: timer) { persistCurrentSetup() }
        .onChange(of: handSize) { persistCurrentSetup() }
        .onChange(of: winScore) { persistCurrentSetup() }
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

    private func currentSetupSnapshot() -> LastSetupSnapshot {
        LastSetupSnapshot(
            cpuPlayers: cpuPlayers,
            defaultCPUDifficulty: defaultCPUDifficulty,
            wordHintsEnabled: wordHintsEnabled,
            timer: timer,
            handSize: handSize,
            winScore: winScore
        )
    }

    private func persistCurrentSetup() {
        guard let data = try? JSONEncoder().encode(currentSetupSnapshot()) else { return }
        UserDefaults.standard.set(data, forKey: lastSetupKey)
    }

    private func loadLastSetupIfAvailable() {
        if let data = UserDefaults.standard.data(forKey: lastSetupKey),
           let snapshot = try? JSONDecoder().decode(LastSetupSnapshot.self, from: data) {
            apply(snapshot)
            return
        }

        loadLegacySetupIfAvailable()
    }

    private func loadLegacySetupIfAvailable() {
        if let rawValue = UserDefaults.standard.string(forKey: legacyDefaultBotSkillKey) {
            let savedDifficulty = CPUDifficulty(savedValue: rawValue)
            defaultCPUDifficulty = savedDifficulty
        }
        
        if let data = UserDefaults.standard.data(forKey: legacyLineupKey),
           let savedLineup = try? JSONDecoder().decode([CPUSetup].self, from: data),
           !savedLineup.isEmpty {
            cpuPlayers = savedLineup
        }

        persistCurrentSetup()
    }

    private func apply(_ snapshot: LastSetupSnapshot) {
        cpuPlayers = snapshot.cpuPlayers.isEmpty
            ? [CPUSetup(name: "Kate", difficulty: snapshot.defaultCPUDifficulty)]
            : snapshot.cpuPlayers
        defaultCPUDifficulty = snapshot.defaultCPUDifficulty
        wordHintsEnabled = snapshot.wordHintsEnabled
        timer = snapshot.timer
        handSize = snapshot.handSize
        winScore = snapshot.winScore
    }

    private func startLocalGame() {
        let config = GameConfig(
            wordHintsEnabled: wordHintsEnabled,
            defaultCPUDifficulty: defaultCPUDifficulty,
            timer: timer,
            handSize: handSize,
            winScore: winScore
        )

        persistCurrentSetup()
        engine.newLocalGame(playerNames: ["Me"], cpuPlayers: cpuPlayers, config: config, humanClerkId: nil)

        dismiss()
    }
}

private struct SetupHeaderTile: View {
    let letter: String
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.96, blue: 0.86),
                        Color(red: 0.93, green: 0.89, blue: 0.78)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(Color(red: 0.88, green: 0.74, blue: 0.42), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 1.5, x: 0, y: 1)
            .overlay(
                Text(letter)
                    .font(.system(size: size * 0.52, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.14))
            )
    }
}

private struct SetupHeaderMarkView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.06, green: 0.09, blue: 0.14))
                .frame(width: 64, height: 64)

            ZStack {
                SetupHeaderMarkTile(letter: "T", size: 23)
                    .rotationEffect(.degrees(6))
                    .offset(x: 8, y: -7)

                SetupHeaderMarkTile(letter: "A", size: 23)
                    .rotationEffect(.degrees(-6))
                    .offset(x: -7, y: 9)

                SetupHeaderMarkTile(letter: "R", size: 26)
                    .offset(x: 0, y: 1)

                Text("+")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.14))
                    .frame(width: 16, height: 16)
                    .background(
                        Circle()
                            .fill(Color(red: 0.98, green: 0.77, blue: 0.22))
                    )
                    .shadow(color: Color.black.opacity(0.16), radius: 1, x: 0, y: 1)
                    .offset(x: 17, y: -18)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct SetupHeaderMarkTile: View {
    let letter: String
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.96, blue: 0.86),
                        Color(red: 0.93, green: 0.89, blue: 0.78)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(Color(red: 0.88, green: 0.74, blue: 0.42), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 1.5, x: 0, y: 1)
            .overlay(
                Text(letter)
                    .font(.system(size: size * 0.52, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.14))
            )
    }
}
