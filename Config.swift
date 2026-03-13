import Foundation

enum Config {
    // ── Dictionary API ────────────────────────────────────
    static let dictionaryBaseURL = "https://api.dictionaryapi.dev/api/v2/entries/en/"

    // ── Game ──────────────────────────────────────────────
    static let handSize = 7
    static let winScore = 20
    static let cpuThinkTimeSeconds: Double = 1.4
}
