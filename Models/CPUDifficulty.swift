//
//  CPUDifficulty.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

enum CPUDifficulty: String, Codable, CaseIterable, Identifiable {
    case novice = "Novice"
    case adept = "Skilled"
    case expert = "Expert"
    case master = "Master"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .novice: return "Novice"
        case .adept: return "Skilled"
        case .expert: return "Expert"
        case .master: return "Master"
        }
    }
}
