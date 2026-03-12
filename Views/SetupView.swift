import SwiftUI

struct SetupView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss

    @State private var cpuCount: Int = 1
    @State private var mode: GameMode = .easy
    @State private var timer: TurnTimerOption = .off
    @State private var allowBlindSwapAfterTimeout: Bool = true
    @State private var handSize: Int = 7
    @State private var winScore: Int = 20
    @State private var showRules = false

    private let maxPlayers = 10
    private let botNames = ["Kate", "Claire", "Henry", "Jack", "Sims", "Miles", "Lukes", "Charlotte", "Peggy"]

    var body: some View {
        ZStack {
            Color(hex: "F4FAFF").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        Text("One Up")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "2563EB"))
                            .frame(maxWidth: .infinity)

                        Text("Add a letter. Steal the lead!")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "60A5FA"))
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 8)

                    settingsCard
                    lineupCard

                    Color.clear
                        .frame(height: 92)
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) {
            bottomStartBar
        }
        .sheet(isPresented: $showRules) {
            rulesSheet
        }
    }

    private var totalPlayerCount: Int {
        1 + cpuCount
    }

    private var maxAllowedCPUCount: Int {
        max(1, maxPlayers - 1)
    }

    private var primaryPlayerName: String {
        "Me"
    }

    private var bottomStartBar: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.96))
                .ignoresSafeArea(edges: .bottom)
                .frame(height: 82)

            Button(action: startLocalGame) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Start Game")
                }
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: 320)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: "2563EB"))
                )
                .shadow(color: Color(hex: "93C5FD").opacity(0.45), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
        }
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Settings")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "1E3A8A"))

                Spacer()

                Button {
                    showRules = true
                } label: {
                    Image(systemName: "book.closed")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "2563EB"))
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(hex: "EFF6FF"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color(hex: "BFDBFE"), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            pickerRow(title: "Mode", selectionText: mode.rawValue) {
                Picker("Mode", selection: $mode) {
                    ForEach(GameMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
            }

            pickerRow(title: "Turn Timer", selectionText: timer.displayName) {
                Picker("Turn Timer", selection: $timer) {
                    ForEach(TurnTimerOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
            }

            if timer != .off {
                toggleRow(title: "Use Card Swap Penalty", isOn: $allowBlindSwapAfterTimeout)
            }

            stepperRow(title: "Cards in Hand", valueText: "\(handSize)") {
                handSize = max(3, handSize - 1)
            } onPlus: {
                handSize = min(12, handSize + 1)
            }

            stepperRow(title: "Winning Score", valueText: "\(winScore)") {
                winScore = max(5, winScore - 5)
            } onPlus: {
                winScore = min(100, winScore + 5)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "D6EAFE"), lineWidth: 1)
        )
    }

    private var lineupCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Lineup")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "1E3A8A"))

                Spacer()

                Button {
                    guard totalPlayerCount < maxPlayers else { return }
                    cpuCount = min(maxAllowedCPUCount, cpuCount + 1)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add Player")
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(
                        Capsule(style: .continuous)
                            .fill(totalPlayerCount < maxPlayers ? Color(hex: "0EA5E9") : Color(hex: "D1D5DB"))
                    )
                }
                .buttonStyle(.plain)
                .disabled(totalPlayerCount >= maxPlayers)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                lineupChip(
                    title: primaryPlayerName,
                    systemName: "person.fill",
                    tint: Color(hex: "2563EB"),
                    removable: false
                ) { }

                ForEach(Array((0..<cpuCount).enumerated()), id: \.offset) { entry in
                    lineupChip(
                        title: botNames[entry.offset % botNames.count],
                        systemName: "cpu",
                        tint: Color(hex: "0EA5E9"),
                        removable: cpuCount > 1
                    ) {
                        removeCPU(at: entry.offset)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "D6EAFE"), lineWidth: 1)
        )
    }

    private func pickerRow<Content: View>(title: String, selectionText: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "334155"))

            Spacer()

            Menu {
                content()
            } label: {
                HStack(spacing: 8) {
                    Text(selectionText)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "2563EB"))
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color(hex: "EFF6FF"))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color(hex: "BFDBFE"), lineWidth: 1)
                )
            }
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "475569"))

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(hex: "0EA5E9"))
        }
    }

    private func stepperRow(title: String, valueText: String, onMinus: @escaping () -> Void, onPlus: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "334155"))

            Spacer()

            HStack(spacing: 10) {
                adjustButton(systemName: "minus", action: onMinus)

                Text(valueText)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "2563EB"))
                    .frame(minWidth: 34)

                adjustButton(systemName: "plus", action: onPlus)
            }
        }
    }

    private func adjustButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(Color(hex: "2563EB"))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(hex: "EFF6FF"))
                )
                .overlay(
                    Circle()
                        .stroke(Color(hex: "BFDBFE"), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func lineupChip(title: String, systemName: String, tint: Color, removable: Bool, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(tint)

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "1F2937"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 4)

            if removable {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "60A5FA"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: "F8FBFF"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(hex: "D6EAFE"), lineWidth: 1)
        )
    }

    private var rulesSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("How to Play")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "2563EB"))

                    ruleLine("1. Select Letters from Hand to spell word")
                    ruleLine("2. Add or Swap Letters each turn")
                    ruleLine("3. Word cannot be used twice per round")
                    ruleLine("4. Discard to draw new letters")
                    ruleLine("5. Pass when cannot play a letter")

                    Text("Scoring")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "2563EB"))
                        .padding(.top, 6)

                    ruleLine("Letters 1-4 are one point each")
                    ruleLine("Letters 5+ are two points each")
                    ruleLine("Points awarded to last player to add letters when each player passes")
                }
                .padding(20)
            }
            .background(Color(hex: "F4FAFF").ignoresSafeArea())
            .navigationTitle("Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showRules = false
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "2563EB"))
                }
            }
        }
    }

    private func ruleLine(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundColor(Color(hex: "1F2937"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func removeCPU(at index: Int) {
        guard cpuCount > 1 else { return }
        guard index >= 0, index < cpuCount else { return }
        cpuCount -= 1
    }

    private func startLocalGame() {
        let config = GameConfig(
            mode: mode,
            timer: timer,
            allowBlindSwapAfterTimeout: allowBlindSwapAfterTimeout,
            handSize: handSize,
            winScore: winScore
        )

        engine.newLocalGame(
            playerNames: [primaryPlayerName],
            cpuCount: cpuCount,
            config: config,
            humanClerkId: authManager.userId
        )

        dismiss()
    }
}
