//
//  DraftInsert.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//
import Foundation

struct DraftInsert: Identifiable, Codable, Equatable {
    let id: UUID
    let handIndex: Int
    let position: Int
    let order: Int

    init(id: UUID = UUID(), handIndex: Int, position: Int, order: Int) {
        self.id = id
        self.handIndex = handIndex
        self.position = position
        self.order = order
    }
}
