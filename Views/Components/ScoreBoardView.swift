import SwiftUI

struct ScoreBoardView: View {
    let players: [Player]
    let currentPlayerIndex: Int
    let winScore: Int

    private var totalPlayers: Int { players.count }

    // Use up to 3 rows when the table gets crowded.
    private var targetRows: Int {
        if totalPlayers > 4 { return 3 }
        return 2
    }

    private var columnCount: Int {
        max(1, Int(ceil(Double(totalPlayers) / Double(targetRows))))
    }

    private var gridItems: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: interItemSpacing),
            count: columnCount
        )
    }

    private var interItemSpacing: CGFloat {
        compactMode ? 4 : 6
    }

    private var compactMode: Bool {
        totalPlayers >= 8
    }

    private var ultraCompactMode: Bool {
        totalPlayers >= 10
    }

    private var nameFont: CGFloat {
        if ultraCompactMode { return 10 }
        if compactMode { return 10.5 }
        if columnCount >= 4 { return 11.5 }
        return 13
    }

    private var secondaryFont: CGFloat {
        max(8.5, nameFont - 2)
    }

    private var scoreFont: CGFloat {
        if ultraCompactMode { return 15 }
        if compactMode { return 16 }
        if columnCount >= 4 { return 18 }
        return 22
    }

    private var cardPadding: CGFloat {
        compactMode ? 6 : 8
    }

    private var cardMinHeight: CGFloat {
        if ultraCompactMode { return 46 }
        if compactMode { return 50 }
        if columnCount >= 4 { return 58 }
        return 72
    }

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: interItemSpacing) {
            ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                card(player: player, index: index)
            }
        }
    }

    private func card(player: Player, index: Int) -> some View {
        let isCurrent = index == currentPlayerIndex

        return VStack(alignment: .leading, spacing: compactMode ? 1 : 3) {
            Text(primaryLabel(for: player))
                .font(.system(size: nameFont, weight: .semibold))
                .foregroundColor(isCurrent ? Theme.navy : Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            if !ultraCompactMode {
                Text(secondaryLabel(for: player))
                    .font(.system(size: secondaryFont, weight: .regular))
                    .foregroundColor(Theme.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(player.score)")
                    .font(.system(size: scoreFont, weight: .bold, design: .serif))
                    .foregroundColor(isCurrent ? Theme.navy : Theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !compactMode {
                    Text("/ \(winScore)")
                        .font(.system(size: max(9, nameFont - 1), weight: .regular))
                        .foregroundColor(Theme.gray)
                        .lineLimit(1)
                }
            }
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity, minHeight: cardMinHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: compactMode ? 5 : 6, style: .continuous)
                .fill(isCurrent ? Theme.navyLight : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: compactMode ? 5 : 6, style: .continuous)
                .stroke(
                    isCurrent ? Theme.navy.opacity(0.40) : Theme.border,
                    lineWidth: isCurrent ? 1.5 : 1
                )
        )
    }

    private func primaryLabel(for player: Player) -> String {
        if player.isComputer {
            return player.displayName
        } else {
            return "You"
        }
    }

    private func secondaryLabel(for player: Player) -> String {
        if player.isComputer {
            return player.cpuDifficulty?.shortLabel ?? "Bot"
        } else {
            return "You"
        }
    }
}
