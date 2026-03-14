import SwiftUI

struct GameView: View {
    @EnvironmentObject var engine: GameEngine
    @State private var showSettings = false
    @State private var showNewGameSheet = false
    @State private var showHelp = false
    @State private var definitionWord: String?

    var body: some View {
        ZStack {
            Theme.bgPage.ignoresSafeArea()

            if let state = engine.state {
                VStack(spacing: 10) {
                    GameHeaderView(
                        state: state,
                        isMyTurn: engine.isMyTurn,
                        remainingSeconds: engine.remainingSeconds(),
                        onHelp: { showHelp = true },
                        onNewGame: { showNewGameSheet = true },
                        onSettings: { showSettings = true }
                    )

                    ScoreBoardView(
                        players: state.players,
                        currentPlayerIndex: state.currentPlayerIndex,
                        winScore: state.config.winScore
                    )

                    Spacer(minLength: 0)

                    boardTopStrip(state: state)
                        .transaction { $0.animation = nil }

                    boardRegion(state: state)
                        .transaction { $0.animation = nil }

                    turnStrip
                        .transaction { $0.animation = nil }

                    HandView()
                        .opacity(state.phase == .gameOver ? 0.65 : 1)
                        .allowsHitTesting(state.phase != .gameOver)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }

            if let definitionWord {
                WordDefinitionOverlayView(word: definitionWord) {
                    self.definitionWord = nil
                }
                .zIndex(30)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(engine)
        }
        .sheet(isPresented: $showNewGameSheet) {
            NavigationStack { SetupView().environmentObject(engine) }
        }
        .alert("How to Play", isPresented: $showHelp) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Select one card, then tap where it goes on the word. After placing it, select another card or press Play. If you select multiple cards before choosing an action, discard is the valid path. On the first play of a round, letters are played in the order you tap them.")
        }
        .onAppear {
            engine.scheduleCoachEvaluation(after: 3.5)
        }
    }

    private var turnStrip: some View {
        ZStack {
            if engine.isMyTurn {
                Text("Your Turn")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Theme.navy))
            }

            HStack {
                Spacer()
                if engine.isMyTurn, let s = engine.remainingSeconds() {
                    Text("\(s)s")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(s <= 5 ? Theme.crimson : Theme.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 24)
        .padding(.top, 2)
    }

    @ViewBuilder
    private func boardTopStrip(state: GameState) -> some View {
        ZStack {
            Color.clear

            if state.phase != .gameOver {
                if let coachTip = engine.coachTip, !coachTip.isEmpty {
                    CoachTipPill(text: coachTip)
                } else if let passText = passStatusText(state: state) {
                    PassiveInfoPill(text: passText)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 28)
        .padding(.bottom, 2)
    }

    @ViewBuilder
    private func boardRegion(state: GameState) -> some View {
        ZStack {
            WordAreaView { tappedWord in
                definitionWord = tappedWord
            }
            .opacity(state.phase == .gameOver ? 0 : 1)

            if state.phase == .gameOver, let winner = state.winnerName {
                WinnerBoardOverlayView(
                    winner: winner,
                    score: state.players.first(where: { $0.displayName == winner })?.score ?? 0,
                    onNewGame: { showNewGameSheet = true }
                )
            }
        }
    }

    private func passStatusText(state: GameState) -> String? {
        guard state.phase == .playing, state.consecutivePasses > 0 else { return nil }
        return "Passes: \(state.consecutivePasses) of \(state.players.count)"
    }
}

private struct CoachTipPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Theme.navy)
            .lineLimit(1)
            .minimumScaleFactor(0.88)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Theme.goldLight)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Theme.gold.opacity(0.26), lineWidth: 1)
            )
    }
}

private struct PassiveInfoPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Theme.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Theme.border, lineWidth: 1)
            )
    }
}

private struct WinnerBoardOverlayView: View {
    let winner: String
    let score: Int
    let onNewGame: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Winner")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.70))
                .textCase(.uppercase)
                .kerning(0.8)

            Text(winner)
                .font(.system(size: 26, weight: .bold, design: .serif))
                .italic()
                .foregroundColor(.white)

            Text("\(score) points")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.white.opacity(0.85))

            Button(action: onNewGame) {
                Text("New Game")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.navy)
                    .padding(.horizontal, 10)
                    .frame(height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color.white)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, minHeight: 188, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.navy)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.border.opacity(0.25), lineWidth: 1)
        )
    }
}
