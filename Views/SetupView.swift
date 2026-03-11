import SwiftUI

struct SetupView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss

    @State private var playerNames: [String] = [""]
    @State private var cpuCount: Int = 1
    @State private var mode: GameMode = .easy
    @State private var timer: TurnTimerOption = .off
    @State private var allowBlindSwapAfterTimeout: Bool = true
    @State private var handSize: Int = 7

    @State private var inviteCode: String = ""
    @State private var isCreatingOnlineGame: Bool = false
    @State private var setupMode: SetupMode = .local

    private let maxPlayers = 10

    var body: some View {
        ZStack {
            Color(hex: "F7F6F2").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    header
                    modeStrip

                    if setupMode == .local {
                        localCard
                    } else {
                        onlineCard
                    }

                    rulesCard
                    footerButtons
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            seedInitialPlayerName()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Word Builder")
                    .font(.system(size: 26, weight: .black, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "6E4DD8"))

                Text("Set up a cleaner game.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "6B7280"))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Close")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Mode Strip

    private var modeStrip: some View {
        HStack(spacing: 8) {
            stripButton("Local", value: .local)
            stripButton("Online", value: .online)
        }
    }

    private func stripButton(_ title: String, value: SetupMode) -> some View {
        let selected = setupMode == value

        return Button {
            setupMode = value
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(selected ? .white : Color(hex: "111827"))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(selected ? Color(hex: "6E4DD8") : .white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(selected ? Color.clear : Color(hex: "D1D5DB"), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Cards

    private var localCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Players")

            VStack(spacing: 8) {
                ForEach(playerNames.indices, id: \.self) { index in
                    HStack(spacing: 8) {
                        Text(index == 0 ? "You" : "P\(index + 1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "6B7280"))
                            .frame(width: 38, alignment: .leading)

                        TextField(index == 0 ? "Your name" : "Player name", text: bindingForPlayerName(at: index))
                            .padding(.horizontal, 12)
                            .frame(height: 42)
                            .background(fieldFill)
                            .overlay(fieldStroke)

                        if index > 0 {
                            Button {
                                removeHumanPlayer(at: index)
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
                    Button {
                        addHumanPlayer()
                    } label: {
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

            divider

            sectionTitle("Computer Players")

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

            cpuPreview

            divider

            sectionTitle("Rules")

            VStack(spacing: 10) {
                modeRow
                timerRow

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

                toggleRow(
                    title: "Blind Swap After Timeout",
                    subtitle: "The next player may choose a random swap after a timeout.",
                    isOn: $allowBlindSwapAfterTimeout
                )
            }
        }
        .cardStyle()
    }

    private var onlineCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Online Game")

            TextField("Your display name", text: bindingForPlayerName(at: 0))
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(fieldFill)
                .overlay(fieldStroke)

            VStack(spacing: 10) {
                modeRow
                timerRow

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

                toggleRow(
                    title: "Blind Swap After Timeout",
                    subtitle: "Applies in online play too.",
                    isOn: $allowBlindSwapAfterTimeout
                )
            }

            divider

            Button {
                Task { await createOnlineGame() }
            } label: {
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
                    .background(fieldFill)
                    .overlay(fieldStroke)

                Button {
                    Task { await joinOnlineGame() }
                } label: {
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
        .cardStyle()
    }

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("How Play Works")

            summaryLine("Select a card, then tap where it goes.")
            summaryLine("First play uses the order you tapped the letters.")
            summaryLine("After placing one, you can add another or press Play.")
            summaryLine("If you select multiple cards before choosing an action, discard becomes the path.")
        }
        .cardStyle()
    }

    private var footerButtons: some View {
        VStack(spacing: 8) {
            if setupMode == .local {
                Button {
                    startLocalGame()
                } label: {
                    Text("Start Local Game")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "6E4DD8"))
                        )
                }
                .buttonStyle(.plain)
            }

            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Reusable Rows

    private var modeRow: some View {
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
    }

    private var timerRow: some View {
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
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Toggle(isOn: isOn) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))
            }
            .tint(Color(hex: "6E4DD8"))

            Text(subtitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "6B7280"))
        }
    }

    private var cpuPreview: some View {
        let names = cpuNamesPreview(count: cpuCount)

        return VStack(alignment: .leading, spacing: 8) {
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

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .black, design: .serif))
            .italic()
            .foregroundColor(Color(hex: "6E4DD8"))
    }

    private func summaryLine(_ text: String) -> some View {
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

    // MARK: - Helpers

    private var fieldFill: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.white)
    }

    private var fieldStroke: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(hex: "E5E7EB"))
            .frame(height: 1)
    }

    private var canAddHumanPlayer: Bool {
        totalPlayerCount < maxPlayers && playerNames.count < maxPlayers
    }

    private var totalPlayerCount: Int {
        playerNames.count + cpuCount
    }

    private var maxAllowedCPUCount: Int {
        max(0, maxPlayers - playerNames.count)
    }

    private var canJoinOnlineGame: Bool {
        !inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var primaryPlayerName: String {
        let trimmed = playerNames.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty { return trimmed }
        if !authManager.playerName.isEmpty { return authManager.playerName }
        return "You"
    }

    private func addHumanPlayer() {
        guard canAddHumanPlayer else { return }
        playerNames.append("")
        if cpuCount > maxAllowedCPUCount {
            cpuCount = maxAllowedCPUCount
        }
    }

    private func removeHumanPlayer(at index: Int) {
        guard index > 0, playerNames.indices.contains(index) else { return }
        playerNames.remove(at: index)
        if cpuCount > maxAllowedCPUCount {
            cpuCount = maxAllowedCPUCount
        }
    }

    private func bindingForPlayerName(at index: Int) -> Binding<String> {
        Binding(
            get: {
                guard playerNames.indices.contains(index) else { return "" }
                return playerNames[index]
            },
            set: { newValue in
                guard playerNames.indices.contains(index) else { return }
                playerNames[index] = newValue
            }
        )
    }

    private func seedInitialPlayerName() {
        if playerNames.isEmpty {
            playerNames = [""]
        }

        if playerNames[0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !authManager.playerName.isEmpty {
            playerNames[0] = authManager.playerName
        }
    }

    private func cpuNamesPreview(count: Int) -> [String] {
        let names = ["Mabel", "Otis", "Pearl", "Walter", "Hazel", "June", "Frankie", "Ruth", "Archie", "Irene"]
        return Array(names.prefix(max(0, count)))
    }

    // MARK: - Actions

    private func startLocalGame() {
        let cleanedNames = playerNames.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let config = GameConfig(
            mode: mode,
            timer: timer,
            allowBlindSwapAfterTimeout: allowBlindSwapAfterTimeout,
            handSize: handSize
        )

        engine.newLocalGame(
            playerNames: cleanedNames,
            cpuCount: cpuCount,
            config: config,
            humanClerkId: authManager.userId
        )
    }

    private func createOnlineGame() async {
        guard !isCreatingOnlineGame else { return }

        isCreatingOnlineGame = true

        let cleanedNames = playerNames.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let config = GameConfig(
            mode: mode,
            timer: timer,
            allowBlindSwapAfterTimeout: allowBlindSwapAfterTimeout,
            handSize: handSize
        )

        engine.newLocalGame(
            playerNames: [cleanedNames.first ?? authManager.playerName],
            cpuCount: 0,
            config: config,
            humanClerkId: authManager.userId
        )

        await engine.createMultiplayerGame()
        isCreatingOnlineGame = false
    }

    private func joinOnlineGame() async {
        let trimmed = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return }

        await authManager.savePlayerName(primaryPlayerName)
        await engine.joinMultiplayerGame(with: trimmed)
    }
}

private enum SetupMode {
    case local
    case online
}

private extension View {
    func cardStyle() -> some View {
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
