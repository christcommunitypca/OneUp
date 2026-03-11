import SwiftUI
import ClerkKit
import ClerkKitUI

struct ContentView: View {
    @Environment(Clerk.self) private var clerk
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        Group {
            if clerk.user != nil {
                authenticatedRoot
                    .task(id: clerk.user?.id) {
                        await authManager.setAuthenticatedUser(id: clerk.user?.id)

                        if let currentName = clerk.user?.firstName,
                           authManager.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            await authManager.savePlayerName(currentName)
                        }
                    }
            } else {
                unauthenticatedRoot
            }
        }
        .animation(.easeInOut(duration: 0.2), value: clerk.user != nil)
    }

    // MARK: - Authenticated

    @ViewBuilder
    private var authenticatedRoot: some View {
        if engine.state == nil {
            NavigationStack {
                SetupView()
            }
        } else {
            NavigationStack {
                GameView()
            }
        }
    }

    // MARK: - Unauthenticated

    @ViewBuilder
    private var unauthenticatedRoot: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Word Builder")
                        .font(.system(size: 34, weight: .black, design: .serif))
                        .italic()
                        .foregroundColor(Theme.violet)

                    Text("A cleaner word game for grown-up game night.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.gray)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 14) {
                    ClerkKitUI.AuthView()
                        .frame(maxWidth: 420)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Theme.white.opacity(0.94))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Theme.violet.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Theme.violet.opacity(0.08), radius: 18, y: 6)
                .padding(.horizontal, 20)

                Spacer()

                Text("Sign in to save your name and play online.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.gray)
                    .padding(.bottom, 18)
            }
        }
    }
}
