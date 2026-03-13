//
//  GameMove.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//
import Foundation

struct GameMove: Codable {
    let playerId: UUID
    let action: GameAction
    let summary: String
    let timestamp: Date

    init(playerId: UUID, action: GameAction, summary: String, timestamp: Date = Date()) {
        self.playerId = playerId
        self.action = action
        self.summary = summary
        self.timestamp = timestamp
    }
}
