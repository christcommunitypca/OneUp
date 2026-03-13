import Foundation

struct GameConfig: Codable, Equatable {
    var wordHintsEnabled: Bool
    var defaultCPUDifficulty: CPUDifficulty
    var timer: TurnTimerOption
    var handSize: Int
    var winScore: Int

    init(
        wordHintsEnabled: Bool = true,
        defaultCPUDifficulty: CPUDifficulty = .adept,
        timer: TurnTimerOption = .off,
        handSize: Int = 7,
        winScore: Int = 20
    ) {
        self.wordHintsEnabled = wordHintsEnabled
        self.defaultCPUDifficulty = defaultCPUDifficulty
        self.timer = timer
        self.handSize = handSize
        self.winScore = winScore
    }
}
