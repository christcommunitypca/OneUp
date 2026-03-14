import Foundation

enum CPUDifficulty: String, Codable, CaseIterable, Identifiable {
    case rookie = "Rookie"
    case pro = "Pro"
    case elite = "Elite"
    case expert = "Expert"
    case master = "Master"

    var id: String { rawValue }
    var shortLabel: String { rawValue }

    init(savedValue: String) {
        let normalized = savedValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch normalized {
        case "rookie", "newb", "noob", "novice":
            self = .rookie
        case "pro", "skilled", "adept", "intermediate":
            self = .pro
        case "elite", "advanced":
            self = .elite
        case "expert":
            self = .expert
        case "master":
            self = .master
        default:
            self = .pro
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = CPUDifficulty(savedValue: raw)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
