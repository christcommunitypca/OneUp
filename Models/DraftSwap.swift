//
//  DraftSwap.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//
import Foundation

struct DraftSwap: Identifiable, Codable, Equatable {
    let id: UUID
    let handIndex: Int
    let wordIndex: Int
    let order: Int

    init(id: UUID = UUID(), handIndex: Int, wordIndex: Int, order: Int) {
        self.id = id
        self.handIndex = handIndex
        self.wordIndex = wordIndex
        self.order = order
    }
}
