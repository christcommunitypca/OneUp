import SwiftUI

struct ScoreBoardView: View {
    let players: [Player]
    let currentPlayerIndex: Int

    var body: some View {
        let columns = players.count <= 4 ? players.count : 3
        let gridItems = Array(repeating: GridItem(.flexible(), spacing: 8), count: max(1, columns))

        LazyVGrid(columns: gridItems, spacing: 8) {
            ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                card(player: player, index: index)
            }
        }
    }

    private func card(player: Player, index: Int) -> some View {
        let current = index == currentPlayerIndex

        return VStack(alignment: .leading, spacing: 6) {
            Text(player.displayName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(current ? Theme.violet : Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(player.isComputer ? "Computer" : "Player")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Theme.gray)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(player.score)")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(Theme.text)

                Text("/ \(Config.winScore)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Theme.gray)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
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
