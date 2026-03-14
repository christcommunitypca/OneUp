import SwiftUI

struct GameHeaderView: View {
    let state: GameState
    let isMyTurn: Bool
    let remainingSeconds: Int?
    let onHelp: () -> Void
    let onNewGame: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            GameTitleMarkView(size: 42)

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

private struct GameTitleMarkView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.06, green: 0.09, blue: 0.14))
                .frame(width: size, height: size)

            ZStack {
                GameTitleMarkTile(letter: "T", size: size * 0.36)
                    .rotationEffect(.degrees(6))
                    .offset(x: size * 0.13, y: -size * 0.11)

                GameTitleMarkTile(letter: "A", size: size * 0.36)
                    .rotationEffect(.degrees(-6))
                    .offset(x: -size * 0.11, y: size * 0.15)

                GameTitleMarkTile(letter: "R", size: size * 0.41)
                    .offset(x: 0, y: size * 0.02)

                Text("+")
                    .font(.system(size: size * 0.18, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.14))
                    .frame(width: size * 0.26, height: size * 0.26)
                    .background(
                        Circle()
                            .fill(Color(red: 0.98, green: 0.77, blue: 0.22))
                    )
                    .shadow(color: Color.black.opacity(0.16), radius: 1, x: 0, y: 1)
                    .offset(x: size * 0.28, y: -size * 0.30)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct GameTitleMarkTile: View {
    let letter: String
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: max(6, size * 0.28), style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.96, blue: 0.86),
                        Color(red: 0.93, green: 0.89, blue: 0.78)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: max(6, size * 0.28), style: .continuous)
                    .stroke(Color(red: 0.88, green: 0.74, blue: 0.42), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 1.5, x: 0, y: 1)
            .overlay(
                Text(letter)
                    .font(.system(size: size * 0.52, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.14))
            )
    }
}
