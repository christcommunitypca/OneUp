import Foundation

enum DictionaryService {
    private static var humanCache: [String: Bool] = [:]
    private static var localCache: [String: Bool] = [:]

    static func isValidForHumanTurn(_ word: String) async -> Bool {
        guard let lower = normalized(word) else { return false }

        if let cached = humanCache[lower] { return cached }

        if isLocalWord(lower) {
            humanCache[lower] = true
            return true
        }

        let result = await fetchFromAPI(lower) ?? false
        humanCache[lower] = result
        return result
    }

    static func isValidForCPU(_ word: String) async -> Bool {
        guard let lower = normalized(word) else { return false }
        return isLocalWord(lower)
    }

    static func isValidForLivePreview(_ word: String) async -> Bool {
        guard let lower = normalized(word) else { return false }
        return isLocalWord(lower)
    }

    static func isLocalWord(_ word: String) -> Bool {
        guard let lower = normalized(word) else { return false }

        if let cached = localCache[lower] { return cached }

        let result = LocalWordList.contains(lower)
        localCache[lower] = result
        return result
    }

    private static func normalized(_ word: String) -> String? {
        let lower = word
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard lower.count >= 2 else { return nil }
        return lower
    }

    private static func fetchFromAPI(_ word: String) async -> Bool? {
        guard let url = URL(string: Config.dictionaryBaseURL + word) else { return nil }

        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse else { return nil }
            return http.statusCode == 200
        } catch {
            return nil
        }
    }
}
