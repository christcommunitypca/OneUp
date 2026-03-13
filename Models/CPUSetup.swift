//
//  CPUSetup.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

import Foundation

struct CPUSetup: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var difficulty: CPUDifficulty

    init(id: UUID = UUID(), name: String, difficulty: CPUDifficulty) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
    }
}

