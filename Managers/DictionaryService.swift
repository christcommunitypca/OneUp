import Foundation

enum DictionaryService {
    private static var cache: [String: Bool] = [:]

    static func isValid(_ word: String) async -> Bool {
        let lower = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        print("DICT CHECK RAW:", word)
        print("DICT CHECK LOWER:", lower)

        guard lower.count >= 2 else { return false }

        if let cached = cache[lower] {
            print("DICT CACHE HIT:", lower, cached)
            return cached
        }

        if let result = await fetchFromAPI(lower) {
            print("DICT API RESULT:", lower, result)
            cache[lower] = result
            return result
        }

        let result = LocalWordList.contains(lower)
        print("DICT FALLBACK RESULT:", lower, result)
        cache[lower] = result
        return result
    }

    private static func fetchFromAPI(_ word: String) async -> Bool? {
        guard let url = URL(string: Config.dictionaryBaseURL + word) else { return nil }

        print("DICT URL:", url.absoluteString)

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse else { return nil }

            print("DICT STATUS:", http.statusCode)

            if let body = String(data: data, encoding: .utf8) {
                print("DICT BODY:", body)
            }

            return http.statusCode == 200
        } catch {
            print("DICT ERROR:", error.localizedDescription)
            return nil
        }
    }
}
