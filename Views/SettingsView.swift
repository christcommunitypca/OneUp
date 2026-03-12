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
                        SettingsProfileCardView(
                            editedName: $editedName,
                            isSaving: isSaving,
                            canSaveName: canSaveName,
                            onSave: {
                                Task { await saveName() }
                            }
                        )

                        SettingsAccountCardView(
                            userId: authManager.userId,
                            savedName: authManager.playerName,
                            currentGameLabel: currentGameLabel,
                            isSigningOut: isSigningOut,
                            onLeaveGame: {
                                engine.state = nil
                                dismiss()
                            },
                            onSignOut: {
                                Task { await signOut() }
                            }
                        )
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

    private var canSaveName: Bool {
        !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        editedName.trimmingCharacters(in: .whitespacesAndNewlines) != authManager.playerName
    }

    private var currentGameLabel: String {
        if let state = engine.state {
            return state.phase == .gameOver ? "Finished game" : "Active game"
        }
        return "No active game"
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
        }

        isSigningOut = false
        dismiss()
    }
}
