import SwiftUI

struct SetupHeaderView: View {
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("One Up")
                    .font(.system(size: 26, weight: .black, design: .serif))
                    .italic()
                    .foregroundColor(Theme.violet)
                Text("Add a letter. Steal the lead.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.gray)
            }
            Spacer()
            Button(action: onClose) {
                Text("Close")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.text)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.white))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Theme.borderBold, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}
