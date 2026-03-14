import SwiftUI

struct SetupBottomBar: View {
    let onStartGame: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "F5F1EB")
                .opacity(0.97)

            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
                .frame(maxWidth: .infinity, alignment: .top)

            Button(action: onStartGame) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 13, weight: .bold))

                    Text("Start New Game")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: 300)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.navy)
                )
                .shadow(color: Theme.navy.opacity(0.20), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
    }
}
