import Foundation

enum LocalWordList {
    private static let words: Set<String> = {
        guard let url = Bundle.main.url(forResource: "scowl60_game_words", withExtension: "txt"),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            assertionFailure("Missing bundled resource: scowl60_game_words.txt")
            return []
        }

        let entries = contents
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }

        return Set(entries)
    }()

    static func contains(_ word: String) -> Bool {
        words.contains(word.lowercased())
    }
}
