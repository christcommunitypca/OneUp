//
//  LetterTile.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//
import SwiftUI

struct LetterTile: Identifiable, Equatable, Codable {
    let id: UUID
    var letter: String
    var playerIndex: Int

    init(id: UUID = UUID(), letter: String, playerIndex: Int = -1) {
        self.id = id
        self.letter = letter.uppercased()
        self.playerIndex = playerIndex
    }

    var isVowel: Bool {
        "AEIOU".contains(letter)
    }
}

