import SwiftUI

struct HandView: View {
    @EnvironmentObject var engine: GameEngine

    private let tileHeight: CGFloat = 54
    private let tileSpacing: CGFloat = 6

    var body: some View {
        let hand = engine.visibleHand
        let myTurn = engine.isMyTurn

        VStack(spacing: 0) {
            Rectangle()
                .fill(myTurn ? Color(hex: "6E4DD8") : Color(hex: "D1D5DB"))
                .frame(height: 2)

            VStack(spacing: 10) {
                HandHeaderView(remainingSeconds: engine.remainingSeconds())

                HandTilesRowView(
                    hand: hand,
                    handSize: engine.state?.config.handSize ?? 7,
                    tileHeight: tileHeight,
                    tileSpacing: tileSpacing,
                    isMyTurn: myTurn,
                    pendingTurn: engine.pendingTurn,
                    isDrafted: { index in isDrafted(index) },
                    draftOrder: { index in draftOrder(index) },
                    tileOpacity: { index in tileOpacity(index: index, isMyTurn: myTurn) },
                    onTapTile: { index in
                        engine.toggleHandSelection(at: index)
                    }
                )

                if myTurn {
                    HandActionAreaView(
                        isValidating: engine.isValidating,
                        playButtonTitle: engine.playButtonTitle,
                        playIsDiscard: engine.pendingTurn.action == .discard,
                        canChoosePlay: engine.canChoosePlay,
                        canChooseSwap: engine.canChooseSwap,
                        canChooseDiscard: engine.canChooseDiscard,
                        swapIsActive: engine.pendingTurn.action == .swap,
                        onPlay: {
                            Task { await engine.playSelectedAction() }
                        },
                        onSwap: {
                            engine.chooseSwapMode()
                        },
                        onDiscard: {
                            engine.chooseDiscardMode()
                        },
                        onPass: {
                            engine.pass()
                        },
                        onClear: {
                            engine.clearPendingTurn()
                        }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(Color.white)
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func isDrafted(_ handIndex: Int) -> Bool {
        engine.pendingTurn.insertDrafts.contains(where: { $0.handIndex == handIndex }) ||
        engine.pendingTurn.swapDrafts.contains(where: { $0.handIndex == handIndex }) ||
        (engine.pendingTurn.activeHandIndex == handIndex && engine.pendingTurn.action != .discard)
    }

    private func draftOrder(_ handIndex: Int) -> Int? {
        if engine.pendingTurn.activeHandIndex == handIndex &&
            !engine.pendingTurn.insertDrafts.contains(where: { $0.handIndex == handIndex }) &&
            !engine.pendingTurn.swapDrafts.contains(where: { $0.handIndex == handIndex }) {
            return nil
        }

        if let insert = engine.pendingTurn.insertDrafts.first(where: { $0.handIndex == handIndex }) {
            return insert.order
        }
        if let swap = engine.pendingTurn.swapDrafts.first(where: { $0.handIndex == handIndex }) {
            return swap.order
        }
        return nil
    }

    private func tileOpacity(index: Int, isMyTurn: Bool) -> Double {
        guard isMyTurn else { return 0.92 }
        if engine.pendingTurn.action == .discard {
            return 1.0
        }
        if let active = engine.pendingTurn.activeHandIndex, active != index, engine.pendingTurn.action == .swap {
            return 0.95
        }
        return 1.0
    }
}
