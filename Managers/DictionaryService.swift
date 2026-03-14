import Foundation

enum WordValidationMode {
    case localOnly
    case localThenAPI
}

struct DictionaryDefinitionItem: Identifiable, Hashable {
    let id = UUID()
    let partOfSpeech: String?
    let definition: String
    let example: String?
}

enum DictionaryLookupResult {
    case found(items: [DictionaryDefinitionItem])
    case notFound
    case unavailable
}

enum DictionaryService {
    private static var validityCache: [String: Bool] = [:]
    private static var definitionCache: [String: DictionaryLookupResult] = [:]

    static func isValid(_ word: String, validationMode: WordValidationMode = .localThenAPI) async -> Bool {
        let lower = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard lower.count >= 2 else { return false }

        if LocalWordList.contains(lower) {
            validityCache[lower] = true
            return true
        }

        guard validationMode == .localThenAPI else { return false }

        if let cached = validityCache[lower] {
            return cached
        }

        if let result = await fetchValidityFromAPI(lower) {
            validityCache[lower] = result
            return result
        }

        return false
    }

    static func lookupDefinition(_ word: String) async -> DictionaryLookupResult {
        let lower = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard lower.count >= 2 else { return .notFound }

        if let cached = definitionCache[lower] {
            return cached
        }

        let result = await fetchDefinitionFromAPI(lower)
        definitionCache[lower] = result
        return result
    }

    private static func fetchValidityFromAPI(_ word: String) async -> Bool? {
        guard let url = URL(string: Config.dictionaryBaseURL + word) else { return nil }
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse else { return nil }
            return http.statusCode == 200
        } catch {
            return nil
        }
    }

    private static func fetchDefinitionFromAPI(_ word: String) async -> DictionaryLookupResult {
        guard let url = URL(string: Config.dictionaryBaseURL + word) else { return .unavailable }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse else { return .unavailable }

            if http.statusCode == 404 {
                return .notFound
            }

            guard http.statusCode == 200 else {
                return .unavailable
            }

            let decoded = try JSONDecoder().decode([DictionaryAPIEntry].self, from: data)
            let items = decoded
                .flatMap(\ .meanings)
                .flatMap { meaning in
                    meaning.definitions.map {
                        DictionaryDefinitionItem(
                            partOfSpeech: meaning.partOfSpeech,
                            definition: $0.definition,
                            example: $0.example
                        )
                    }
                }
                .filter { !$0.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            return items.isEmpty ? .notFound : .found(items: Array(items.prefix(8)))
        } catch {
            return .unavailable
        }
    }
}

private struct DictionaryAPIEntry: Decodable {
    let meanings: [DictionaryAPIMeaning]
}

private struct DictionaryAPIMeaning: Decodable {
    let partOfSpeech: String?
    let definitions: [DictionaryAPIDefinition]
}

private struct DictionaryAPIDefinition: Decodable {
    let definition: String
    let example: String?
}
