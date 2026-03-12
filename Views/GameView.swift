import SwiftUI

struct GameView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var authManager: AuthManager

    @State private var showSettings = false
    @State private var showNewGameSheet = false
    @State private var showHelp = false

    var body: some View {
        ZStack {
            Color(hex: "F7F6F2").ignoresSafeArea()

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

                    bannerSection(state: state)

                    Spacer(minLength: 0)

                    if state.consecutivePasses > 0 && state.phase == .playing {
                        CompactStatusView(
                            text: "Passes: \(state.consecutivePasses) of \(state.players.count)"
                        )
                    }

                    WordAreaView()

                    turnStrip

                    HandView()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(authManager)
                .environmentObject(engine)
        }
        .sheet(isPresented: $showNewGameSheet) {
            NavigationStack {
                SetupView()
                    .environmentObject(authManager)
                    .environmentObject(engine)
            }
        }
        .alert("How to Play", isPresented: $showHelp) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Select one card, then tap where it goes on the word. After placing it, select another card or press Play. If you select multiple cards before choosing an action, discard is the valid path. On the first play of a round, letters are played in the order you tap them.")
        }
    }

    @ViewBuilder
    private func bannerSection(state: GameState) -> some View {
        if state.phase == .gameOver, let winner = state.winnerName {
            WinnerBannerView(
                winner: winner,
                score: state.players.first(where: { $0.displayName == winner })?.score ?? 0,
                onNewGame: { showNewGameSheet = true },
                onSettings: { showSettings = true }
            )
        } else if let pending = state.pendingBlindSwap,
                  pending.isAvailable,
                  engine.isBlindSwapPromptVisible,
                  engine.myPlayerIndex == pending.eligiblePlayerIndex {
            BlindSwapBannerView(
                timedOutPlayerName: state.players[pending.timedOutPlayerIndex].displayName,
                onBlindSwap: { engine.acceptBlindSwap() },
                onSkip: { engine.declineBlindSwap() }
            )
        }
    }

    private var turnStrip: some View {
        HStack(spacing: 8) {
            if engine.isMyTurn {
                Text("Your Turn")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(hex: "6E4DD8"))
                    )
            }

            if engine.isMyTurn, let remainingSeconds = engine.remainingSeconds() {
                Text("\(remainingSeconds)s")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(remainingSeconds <= 5 ? Color(hex: "C2410C") : Color(hex: "6E4DD8"))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 28)
        .padding(.top, 2)
        .padding(.bottom, 2)
    }
}
