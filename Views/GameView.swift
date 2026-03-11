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
                        currentPlayerIndex: state.currentPlayerIndex
                    )

                    bannerSection(state: state)

                    WordAreaView()

                    if let state = engine.state {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(state.log.prefix(10).enumerated()), id: \.offset) { _, entry in
                                    Text(entry)
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(8)
                        }
                        .frame(maxHeight: 140)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    if state.consecutivePasses > 0 && state.phase == .playing {
                        CompactStatusView(
                            text: "Passes: \(state.consecutivePasses) of \(state.players.count)"
                        )
                    }

                    Spacer(minLength: 0)

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
}
