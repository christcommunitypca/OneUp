//
//  HandTilesRowView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct HandTilesRowView: View {
    let hand: [LetterTile]
    let handSize: Int
    let tileHeight: CGFloat
    let tileSpacing: CGFloat
    let isMyTurn: Bool
    let pendingTurn: PendingTurn
    let isDrafted: (Int) -> Bool
    let draftOrder: (Int) -> Int?
    let tileOpacity: (Int) -> Double
    let onTapTile: (Int) -> Void

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(0, proxy.size.width)
            let slotCount = max(handSize, hand.count)
            let computedWidth = slotCount > 0
                ? min(44, max(34, (availableWidth - (CGFloat(slotCount - 1) * tileSpacing)) / CGFloat(slotCount)))
                : 44

            HStack(spacing: tileSpacing) {
                ForEach(Array(hand.enumerated()), id: \.element.id) { index, tile in
                    HandTileView(
                        tile: tile,
                        index: index,
                        isStaged: isMyTurn && isDrafted(index),
                        stageOrder: draftOrder(index),
                        isSwapSelected: isMyTurn && pendingTurn.activeHandIndex == index && pendingTurn.action == .swap,
                        isDiscardSelected: isMyTurn && pendingTurn.action == .discard && pendingTurn.discardSelection.contains(index),
                        showVowelHint: false,
                        isEnabled: true
                    ) {
                        onTapTile(index)
                    }
                    .frame(width: computedWidth, height: tileHeight)
                    .allowsHitTesting(isMyTurn)
                    .opacity(tileOpacity(index))
                }

                ForEach(0..<max(0, handSize - hand.count), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color(hex: "D1D5DB"), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .frame(width: computedWidth, height: tileHeight)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: tileHeight + 4)
    }
}
