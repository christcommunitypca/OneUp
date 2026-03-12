import SwiftUI

struct SetupView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss

    @State private var cpuPlayers: [CPUSetup] = [
        CPUSetup(name: "Kate", difficulty: .adept)
    ]
    @State private var defaultCPUDifficulty: CPUDifficulty = .adept
    @State private var mode: GameMode = .easy
    @State private var timer: TurnTimerOption = .off
    @State private var allowBlindSwapAfterTimeout: Bool = true
    @State private var handSize: Int = 7
    @State private var winScore: Int = 20
    @State private var showRules = false

    private let maxPlayers = 10
    private let botNames = ["Kate", "Claire", "Henry", "Jack", "Sims", "Miles", "Luke", "Charlotte", "Peggy"]

    private let settingsControlWidth: CGFloat = 120
    
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
                            .font(.system(size: 30, weight: .bold, design: .serif)).italic()
                            .foregroundColor(Theme.navy).frame(maxWidth: .infinity)
                        Text("Add a letter. Steal the lead.")
                            .font(.system(size: 12, weight: .regular)).foregroundColor(Theme.gray).frame(maxWidth: .infinity)
                    }
                    .padding(.top, 10)

                    settingsCard
                    lineupCard
                    Color.clear.frame(height: 88)
                }
                .padding(.horizontal, 12).padding(.top, 8).padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
        .sheet(isPresented: $showRules) { rulesSheet }
    }

    private var bottomBar: some View {
        ZStack(alignment: .top) {
            Color(hex: "F5F1EB")
                .opacity(0.97)

            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
                .frame(maxWidth: .infinity, alignment: .top)

            Button(action: startLocalGame) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Start Game")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: 300)
                .frame(height: 48)
                .background(RoundedRectangle(cornerRadius: 8).fill(Theme.navy))
                .shadow(color: Theme.navy.opacity(0.20), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Settings").font(.system(size: 16, weight: .bold, design: .serif)).italic().foregroundColor(Theme.navy)
                Spacer()
                Button { showRules = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "book").font(.system(size: 12))
                        Text("Rules").font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Theme.navy)
                     .padding(.horizontal, 10).frame(height: 28)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Theme.border, lineWidth: 1))
                }.buttonStyle(.plain)
            }

            pickerRow(title: "Word Hints", selectionText: mode.rawValue) {
                Picker("Mode", selection: $mode) { ForEach(GameMode.allCases) { Text($0.rawValue).tag($0) } }
            }
            SetupDividerView()
            pickerRow(title: "Default CPU", selectionText: defaultCPUDifficulty.rawValue) {
                Picker("Default CPU", selection: $defaultCPUDifficulty) {
                    ForEach(CPUDifficulty.allCases) { Text($0.rawValue).tag($0) }
                }
            }
            SetupDividerView()
            pickerRow(title: "Turn Timer", selectionText: timer.displayName) {
                Picker("Timer", selection: $timer) { ForEach(TurnTimerOption.allCases) { Text($0.displayName).tag($0) } }
            }
            if timer != .off {
                SetupDividerView()
                toggleRow(title: "Blind Swap Penalty", isOn: $allowBlindSwapAfterTimeout)
            }
            SetupDividerView()
            stepperRow(title: "Cards in Hand", value: handSize) { handSize = max(3, handSize - 1) } onPlus: { handSize = min(12, handSize + 1) }
            SetupDividerView()
            stepperRow(title: "Winning Score", value: winScore) { winScore = max(5, winScore - 5) } onPlus: { winScore = min(100, winScore + 5) }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border, lineWidth: 1))
        .shadow(color: Theme.cardShadow, radius: 3, y: 1)
    }

    private var lineupCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Lineup").font(.system(size: 16, weight: .bold, design: .serif)).italic().foregroundColor(Theme.navy)
                Spacer()
                Button(action: addCPU) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus").font(.system(size: 11, weight: .bold))
                        Text("CPU").font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(canAddCPU ? Theme.navy : Theme.gray)
                    .padding(.horizontal, 10).frame(height: 28)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Theme.border, lineWidth: 1))
                }.buttonStyle(.plain).disabled(!canAddCPU)
            }

            if cpuPlayers.isEmpty {
                Text("No CPU opponents added")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.gray)
            } else {
                VStack(spacing: 8) {
                    ForEach($cpuPlayers) { $cpu in
                        cpuLineupRow(cpu: $cpu)
                    }
                }
            }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border, lineWidth: 1))
        .shadow(color: Theme.cardShadow, radius: 3, y: 1)
    }

    private func pickerRow<Content: View>(title: String, selectionText: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            Menu { content() } label: {
                HStack(spacing: 5) {
                    Text(selectionText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.navy)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Theme.navy)
                }
                .frame(width: settingsControlWidth, height: 28)
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
            .frame(width: settingsControlWidth, alignment: .trailing)
        }
    }

    private func stepperRow(title: String, value: Int, onMinus: @escaping () -> Void, onPlus: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            HStack(spacing: 10) {
                Button(action: onMinus) {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.navy)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Theme.navyLight))
                        .overlay(Circle().stroke(Theme.navy.opacity(0.18), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Text("\(value)")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(Theme.navy)
                    .frame(minWidth: 28)

                Button(action: onPlus) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.navy)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Theme.navyLight))
                        .overlay(Circle().stroke(Theme.navy.opacity(0.18), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .frame(width: settingsControlWidth, alignment: .trailing)
        }
    }

    private func cpuLineupRow(cpu: Binding<CPUSetup>) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "cpu").font(.system(size: 12, weight: .regular)).foregroundColor(Theme.slate)
            Text(cpu.wrappedValue.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            Menu {
                ForEach(CPUDifficulty.allCases) { level in
                    Button(level.rawValue) {
                        cpu.wrappedValue.difficulty = level
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(cpu.wrappedValue.difficulty.shortLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.navy)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(Theme.navy)
                }
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Theme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button(action: { removeCPU(cpu.wrappedValue.id) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Theme.gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10).frame(height: 38)
        .background(RoundedRectangle(cornerRadius: 6).fill(Theme.bgSurface))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border, lineWidth: 1))
    }

    private var rulesSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to Play").font(.system(size: 17, weight: .bold, design: .serif)).italic().foregroundColor(Theme.navy)
                    ruleLine("Select letters from your hand to spell or extend a word.")
                    ruleLine("Add or swap letters each turn.")
                    ruleLine("Discard to draw new letters.")
                    ruleLine("Pass when you cannot play.")
                    Text("Scoring").font(.system(size: 17, weight: .bold, design: .serif)).italic().foregroundColor(Theme.navy).padding(.top, 6)
                    ruleLine("Letters 1–4: one point each.")
                    ruleLine("Letters 5 and beyond: two points each.")
                    ruleLine("Points go to the last player to add letters when all others pass.")
                    ruleLine("First to \(winScore) points wins.")
                }
                .padding(20)
            }
            .background(Theme.bgPage.ignoresSafeArea())
            .navigationTitle("Rules").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showRules = false }.font(.system(size: 14, weight: .medium)).foregroundColor(Theme.navy)
                }
            }
        }
    }

    private func ruleLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("–").foregroundColor(Theme.navy).font(.system(size: 13))
            Text(text).font(.system(size: 14, weight: .regular)).foregroundColor(Theme.textSecondary)
            Spacer()
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
            mode: mode,
            defaultCPUDifficulty: defaultCPUDifficulty,
            timer: timer,
            allowBlindSwapAfterTimeout: allowBlindSwapAfterTimeout,
            handSize: handSize,
            winScore: winScore
        )
        engine.newLocalGame(playerNames: ["Me"], cpuPlayers: cpuPlayers, config: config, humanClerkId: authManager.userId)
        dismiss()
    }
}
