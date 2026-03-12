import Foundation

enum DictionaryValidationMode {
    case localOnly
    case localThenAPI
}

enum DictionaryService {
    private static var cache: [String: Bool] = [:]

    static func isValid(_ word: String, mode: DictionaryValidationMode = .localThenAPI) async -> Bool {
        let lower = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard lower.count >= 2 else { return false }

        if LocalWordList.contains(lower) {
            cache[lower] = true
            return true
        }

        guard mode == .localThenAPI else { return false }

        if let cached = cache[lower] {
            return cached
        }

        if let result = await fetchFromAPI(lower) {
            cache[lower] = result
            return result
        }

        return false
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
