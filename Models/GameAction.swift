//
//  GameAction.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

enum GameAction: String, Codable {
    case play
    case swap
    case discard
    case pass
    case timeout
    case blindSwaplef
    case roundEnd
    case gameOver
}
