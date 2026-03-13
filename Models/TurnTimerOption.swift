//
//  TurnTimerOptions.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

enum TurnTimerOption: Int, Codable, CaseIterable, Identifiable {
    case off = 0
    case ten = 10
    case fifteen = 15
    case twenty = 20
    case thirty = 30
    case fortyFive = 45
    case sixty = 60

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .off: return "Off"
        default: return "\(rawValue)s"
        }
    }

    var seconds: Int? {
        self == .off ? nil : rawValue
    }
}
