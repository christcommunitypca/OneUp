//
//  PendingBlindSwap.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

struct PendingBlindSwap: Codable, Equatable {
    var timedOutPlayerIndex: Int
    var eligiblePlayerIndex: Int
    var isAvailable: Bool

    init(timedOutPlayerIndex: Int, eligiblePlayerIndex: Int, isAvailable: Bool = true) {
        self.timedOutPlayerIndex = timedOutPlayerIndex
        self.eligiblePlayerIndex = eligiblePlayerIndex
        self.isAvailable = isAvailable
    }
}
