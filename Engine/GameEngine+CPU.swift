import Foundation

@MainActor
extension GameEngine {

    func scheduleCPUIfNeeded() {
        cpuTask?.cancel()
        guard let state else { return }
        guard state.phase == .playing else { return }
        guard state.currentPlayer.isComputer else { return }

        cpuTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(Config.cpuThinkTimeSeconds * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await self?.executeCPUTurn()
        }
    }

}
