import Foundation

@MainActor
extension GameEngine {

    func createMultiplayerGame() async {
        guard let state else { return }
        do {
            let code = try await SupabaseManager.shared.createGame(state: state)
            inviteCode = code
            isMultiplayer = true

            var updated = state
            updated.inviteCode = code
            self.state = updated

            await subscribeToCurrentGame()
        } catch {
            validationMessage = "Could not create game"
        }
    }

    func joinMultiplayerGame(with inviteCode: String) async {
        do {
            if let loaded = try await SupabaseManager.shared.loadGame(inviteCode: inviteCode) {
                state = loaded
                self.inviteCode = inviteCode
                isMultiplayer = true
                clearPendingTurn()
                await subscribeToCurrentGame()
                scheduleTurnTimerIfNeeded()
                scheduleCPUIfNeeded()
            } else {
                validationMessage = "Game not found"
            }
        } catch {
            validationMessage = "Could not join game"
        }
    }

    func applyRemoteState(_ newState: GameState) {
        guard isMultiplayer else { return }
        state = newState
        scheduleTurnTimerIfNeeded()
        scheduleCPUIfNeeded()
    }

    private func subscribeToCurrentGame() async {
        guard let id = state?.id else { return }
        await SupabaseManager.shared.subscribeToGame(id: id) { [weak self] newState in
            Task { @MainActor in
                self?.applyRemoteState(newState)
            }
        }
    }

    func syncIfMultiplayer() async {
        guard isMultiplayer, let state else { return }
        try? await SupabaseManager.shared.updateGame(state: state)
    }
}
