import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Game")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                                .italic()
                                .foregroundColor(Theme.navy)

                            HStack {
                                Text("Current Game")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)

                                Spacer()

                                Text(currentGameLabel)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Theme.gray)
                            }
                            
                            NavigationLink {
                                SupportView()
                            } label: {
                                HStack {
                                    Text("Support One Up")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Theme.navy)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Theme.gray)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Theme.border, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)

                            Button {
                                engine.state = nil
                                engine.inviteCode = nil
                                engine.isMultiplayer = false
                                engine.clearPendingTurn()
                                dismiss()
                            } label: {
                                Text("Leave Current Game")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Theme.navy)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.border, lineWidth: 1)
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
        }
    }

    private var currentGameLabel: String {
        if let state = engine.state {
            return state.phase == .gameOver ? "Finished game" : "Active game"
        }
        return "No active game"
    }
}
