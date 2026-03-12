import SwiftUI

struct GameHeaderView: View {
    let state: GameState
    let isMyTurn: Bool
    let remainingSeconds: Int?
    let onHelp: () -> Void
    let onNewGame: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text("One Up")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .italic()
                    .foregroundColor(Theme.navy)
                Text("Add a letter. Steal the lead.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Theme.gray)
                    .kerning(0.2)
            }

            Spacer()

            HStack(spacing: 8) {
                GameHeaderIconButton(systemName: "arrow.uturn.left", label: "New", action: onNewGame)
                GameHeaderIconButton(systemName: "questionmark", label: "Help", action: onHelp)
            }
        }
    }
}

private struct GameHeaderIconButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.navy)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Theme.gray)
            }
            .frame(width: 42, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
