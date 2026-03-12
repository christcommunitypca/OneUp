import SwiftUI

struct ScoreBoardView: View {
    let players: [Player]
    let currentPlayerIndex: Int
    let winScore: Int

    private var columnCount: Int {
        min(players.count, max(2, Int(ceil(Double(players.count) / 2.0))))
    }
    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 6), count: max(1, columnCount))
    }
    private var nameFont: CGFloat { columnCount >= 5 ? 11 : columnCount >= 4 ? 12 : 13 }
    private var scoreFont: CGFloat { columnCount >= 5 ? 18 : columnCount >= 4 ? 20 : 24 }
    private var cardPadding: CGFloat { columnCount >= 5 ? 8 : 10 }
    private var minHeight: CGFloat { columnCount >= 5 ? 66 : columnCount >= 4 ? 72 : 84 }

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 6) {
            ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                card(player: player, index: index)
            }
        }
    }

    private func card(player: Player, index: Int) -> some View {
        let current = index == currentPlayerIndex
        return VStack(alignment: .leading, spacing: 3) {
            Text(player.displayName)
                .font(.system(size: nameFont, weight: .semibold))
                .foregroundColor(current ? Theme.navy : Theme.text)
                .lineLimit(1).minimumScaleFactor(0.65)

            Text(player.isComputer ? "Computer" : "Player")
                .font(.system(size: max(9, nameFont - 2), weight: .regular))
                .foregroundColor(Theme.gray).lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(player.score)")
                    .font(.system(size: scoreFont, weight: .bold, design: .serif))
                    .foregroundColor(current ? Theme.navy : Theme.text)
                    .lineLimit(1).minimumScaleFactor(0.7)
                Text("/ \(winScore)")
                    .font(.system(size: max(9, nameFont - 1), weight: .regular))
                    .foregroundColor(Theme.gray).lineLimit(1)
            }
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(current ? Theme.navyLight : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(current ? Theme.navy.opacity(0.40) : Theme.border, lineWidth: current ? 1.5 : 1)
        )
    }
}
