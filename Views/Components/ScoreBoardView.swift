import SwiftUI

struct ScoreBoardView: View {
    let players: [Player]
    let currentPlayerIndex: Int
    let winScore: Int

    private var columnCount: Int {
        min(players.count, max(2, Int(ceil(Double(players.count) / 2.0))))
    }

    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: max(1, columnCount))
    }

    private var nameFont: CGFloat {
        columnCount >= 5 ? 11 : columnCount >= 4 ? 12 : 13
    }

    private var scoreFont: CGFloat {
        columnCount >= 5 ? 20 : columnCount >= 4 ? 22 : 26
    }

    private var cardPadding: CGFloat {
        columnCount >= 5 ? 8 : 10
    }

    private var minHeight: CGFloat {
        columnCount >= 5 ? 70 : columnCount >= 4 ? 76 : 88
    }

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 8) {
            ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                card(player: player, index: index)
            }
        }
    }

    private func card(player: Player, index: Int) -> some View {
        let current = index == currentPlayerIndex

        return VStack(alignment: .leading, spacing: 4) {
            Text(player.displayName)
                .font(.system(size: nameFont, weight: .bold, design: .rounded))
                .foregroundColor(current ? Theme.violet : Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(player.isComputer ? "Computer" : "Player")
                .font(.system(size: max(9, nameFont - 2), weight: .semibold, design: .rounded))
                .foregroundColor(Theme.gray)
                .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(player.score)")
                    .font(.system(size: scoreFont, weight: .black, design: .rounded))
                    .foregroundColor(Theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("/ \(winScore)")
                    .font(.system(size: max(9, nameFont - 1), weight: .bold, design: .rounded))
                    .foregroundColor(Theme.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(current ? Theme.violet.opacity(0.10) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(current ? Theme.violet.opacity(0.35) : Color(hex: "E6E6EE"), lineWidth: 1)
        )
    }
}
