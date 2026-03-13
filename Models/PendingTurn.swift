//
//  PendingTurn.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

struct PendingTurn: Codable, Equatable {
    var action: PendingAction

    var activeHandIndex: Int?

    var selectedHandIndices: [Int]
    var selectedWordIndices: [Int]
    var insertionPositions: [Int]

    var insertDrafts: [DraftInsert]
    var swapDrafts: [DraftSwap]
    var discardSelection: [Int]

    init(
        action: PendingAction = .none,
        activeHandIndex: Int? = nil,
        selectedHandIndices: [Int] = [],
        selectedWordIndices: [Int] = [],
        insertionPositions: [Int] = [],
        insertDrafts: [DraftInsert] = [],
        swapDrafts: [DraftSwap] = [],
        discardSelection: [Int] = []
    ) {
        self.action = action
        self.activeHandIndex = activeHandIndex
        self.selectedHandIndices = selectedHandIndices
        self.selectedWordIndices = selectedWordIndices
        self.insertionPositions = insertionPositions
        self.insertDrafts = insertDrafts
        self.swapDrafts = swapDrafts
        self.discardSelection = discardSelection
    }

    var hasDraftEdits: Bool {
        !insertDrafts.isEmpty || !swapDrafts.isEmpty
    }

    var selectedHandCount: Int {
        Set(selectedHandIndices).count
    }

    var hasSingleSelection: Bool {
        selectedHandCount == 1
    }

    var hasMultiSelection: Bool {
        selectedHandCount >= 2
    }

    var swapCount: Int {
        swapDrafts.count
    }

    var canAddAnotherSwap: Bool {
        swapDrafts.count < 2
    }

    var isEmpty: Bool {
        activeHandIndex == nil &&
        selectedHandIndices.isEmpty &&
        selectedWordIndices.isEmpty &&
        insertionPositions.isEmpty &&
        insertDrafts.isEmpty &&
        swapDrafts.isEmpty &&
        discardSelection.isEmpty &&
        action == .none
    }
}
