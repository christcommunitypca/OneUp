import Foundation

enum DictionaryService {
    private static var cache: [String: Bool] = [:]

    static func isValid(_ word: String) async -> Bool {
        let lower = word.lowercased()
        guard lower.count >= 2 else { return false }

        if let cached = cache[lower] { return cached }

        if let result = await fetchFromAPI(lower) {
            cache[lower] = result
            return result
        }

        let result = LocalWordList.contains(lower)
        cache[lower] = result
        return result
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
