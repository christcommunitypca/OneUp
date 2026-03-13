//
//  Player.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//
import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var hand: [LetterTile]
    var score: Int
    var isComputer: Bool
    var cpuDifficulty: CPUDifficulty?
    var clerkUserId: String?
    var isCurrentDevice: Bool

    init(
        id: UUID = UUID(),
        name: String,
        hand: [LetterTile] = [],
        score: Int = 0,
        isComputer: Bool = false,
        cpuDifficulty: CPUDifficulty? = nil,
        clerkUserId: String? = nil,
        isCurrentDevice: Bool = false
    ) {
        self.id = id
        self.name = name
        self.hand = hand
        self.score = score
        self.isComputer = isComputer
        self.cpuDifficulty = cpuDifficulty
        self.clerkUserId = clerkUserId
        self.isCurrentDevice = isCurrentDevice
    }

    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Player" : name
    }
}

