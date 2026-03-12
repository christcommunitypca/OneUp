import SwiftUI

struct SettingsInfoRowView: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.system(size: 11, weight: .medium)).foregroundColor(Theme.gray).textCase(.uppercase).kerning(0.4)
            Text(value).font(.system(size: 14, weight: .regular)).foregroundColor(Theme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.bgSurface))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Theme.border, lineWidth: 1))
    }
}

struct SettingsProfileCardView: View {
    @Binding var editedName: String
    let isSaving: Bool
    let canSaveName: Bool
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Profile").font(.system(size: 18, weight: .bold, design: .serif)).italic().foregroundColor(Theme.navy)
            VStack(alignment: .leading, spacing: 6) {
                Text("Display Name").font(.system(size: 11, weight: .medium)).foregroundColor(Theme.gray).textCase(.uppercase).kerning(0.4)
                TextField("Your name", text: $editedName)
                    .font(.system(size: 15)).padding(.horizontal, 12).frame(height: 44)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Theme.bgInput))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.borderBold, lineWidth: 1))
                Text("Shown in local and online games.")
                    .font(.system(size: 11, weight: .regular)).foregroundColor(Theme.gray)
            }
            Button(action: onSave) {
                HStack {
                    if isSaving { ProgressView().tint(.white).scaleEffect(0.8) }
                    Text(isSaving ? "Saving…" : "Save Name").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity).frame(height: 44)
                .background(RoundedRectangle(cornerRadius: 6).fill(canSaveName ? Theme.navy : Theme.lightGray))
            }
            .disabled(!canSaveName || isSaving)
        }
        .panelStyle()
    }
}

struct SettingsAccountCardView: View {
    let userId: String?
    let savedName: String
    let currentGameLabel: String
    let isSigningOut: Bool
    let onLeaveGame: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account").font(.system(size: 18, weight: .bold, design: .serif)).italic().foregroundColor(Theme.navy)
            VStack(alignment: .leading, spacing: 8) {
                if let userId, !userId.isEmpty { SettingsInfoRowView(title: "User ID", value: shortUserId(userId)) }
                SettingsInfoRowView(title: "Saved Name", value: savedName.isEmpty ? "Not set" : savedName)
                SettingsInfoRowView(title: "Current Game", value: currentGameLabel)
            }
            VStack(spacing: 8) {
                Button(action: onLeaveGame) {
                    Text("Leave Current Game").font(.system(size: 14, weight: .regular)).foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.borderBold, lineWidth: 1))
                }
                Button(action: onSignOut) {
                    HStack {
                        if isSigningOut { ProgressView().tint(.white).scaleEffect(0.8) }
                        Text(isSigningOut ? "Signing Out…" : "Sign Out").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity).frame(height: 44)
                    .background(RoundedRectangle(cornerRadius: 6).fill(isSigningOut ? Theme.crimson.opacity(0.60) : Theme.crimson))
                }.disabled(isSigningOut)
            }
        }
        .panelStyle()
    }

    private func shortUserId(_ uid: String) -> String {
        uid.count <= 18 ? uid : "\(uid.prefix(10))…\(uid.suffix(6))"
    }
}
