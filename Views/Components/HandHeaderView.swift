import SwiftUI

struct HandHeaderView: View {
    let remainingSeconds: Int?

    var body: some View {
        HStack {
            Text("Your Hand")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .kerning(0.5)

            Spacer()

            if let seconds = remainingSeconds {
                Text("\(seconds)s")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(seconds <= 5 ? Theme.crimson : Theme.navy)
                    .padding(.horizontal, 8)
                    .frame(height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(seconds <= 5 ? Theme.crimsonLight : Theme.navyLight)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(seconds <= 5 ? Theme.crimson.opacity(0.30) : Theme.navy.opacity(0.25), lineWidth: 1)
                    )
            }
        }
    }
}
