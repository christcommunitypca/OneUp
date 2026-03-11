import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss

    @State private var editedName: String = ""
    @State private var isSaving = false
    @State private var isSigningOut = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        profileCard
                        accountCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.violet)
                    .font(.system(size: 15, weight: .bold))
                }
            }
            .onAppear {
                editedName = authManager.playerName
            }
        }
    }

    // MARK: - Profile

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Profile")
                .font(.system(size: 20, weight: .black, design: .serif))
                .italic()
                .foregroundColor(Theme.violet)

            VStack(alignment: .leading, spacing: 8) {
                Text("Display Name")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.gray)

                TextField("Your name", text: $editedName)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Theme.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.violet.opacity(0.10), lineWidth: 1.1)
                    )

                Text("This name appears in local and online games.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.gray)
            }

            Button {
                Task {
                    await saveName()
                }
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(isSaving ? "Saving..." : "Save Name")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(canSaveName ? Theme.violet : Theme.lightGray)
                )
            }
            .disabled(!canSaveName || isSaving)
        }
        .panelStyle()
    }

    // MARK: - Account

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account")
                .font(.system(size: 20, weight: .black, design: .serif))
                .italic()
                .foregroundColor(Theme.violet)

            VStack(alignment: .leading, spacing: 8) {
                if let uid = authManager.userId, !uid.isEmpty {
                    infoRow(title: "User ID", value: shortUserId(uid))
                }

                infoRow(
                    title: "Saved Name",
                    value: authManager.playerName.isEmpty ? "Not set" : authManager.playerName
                )

                if let state = engine.state {
                    infoRow(title: "Current Game", value: state.phase == .gameOver ? "Finished game" : "Active game")
                } else {
                    infoRow(title: "Current Game", value: "No active game")
                }
            }

            VStack(spacing: 10) {
                Button {
                    engine.state = nil
                    dismiss()
                } label: {
                    Text("Leave Current Game")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Theme.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Theme.violet.opacity(0.12), lineWidth: 1.1)
                        )
                }

                Button {
                    Task {
                        await signOut()
                    }
                } label: {
                    HStack {
                        if isSigningOut {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(isSigningOut ? "Signing Out..." : "Sign Out")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isSigningOut ? Theme.coral.opacity(0.65) : Theme.coral)
                    )
                }
                .disabled(isSigningOut)
            }
        }
        .panelStyle()
    }

    // MARK: - Helpers

    private var canSaveName: Bool {
        !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        editedName.trimmingCharacters(in: .whitespacesAndNewlines) != authManager.playerName
    }

    private func saveName() async {
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSaving = true
        await authManager.savePlayerName(trimmed)
        editedName = trimmed
        isSaving = false
    }

    private func signOut() async {
        isSigningOut = true

        engine.state = nil
        engine.inviteCode = nil
        engine.isMultiplayer = false
        engine.clearPendingTurn()

        do {
            try await authManager.signOut()
        } catch {
            // Keep the UI stable even if provider sign-out is noisy.
        }

        isSigningOut = false
        dismiss()
    }

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Theme.gray)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.white.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.violet.opacity(0.08), lineWidth: 1)
        )
    }

    private func shortUserId(_ uid: String) -> String {
        if uid.count <= 18 { return uid }
        return "\(uid.prefix(10))...\(uid.suffix(6))"
    }
}
