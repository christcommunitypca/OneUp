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
                        if let name = clerk.user?.firstName,
                           authManager.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            await authManager.savePlayerName(name)
                        }
                    }
            } else {
                unauthenticatedRoot
            }
        }
        .animation(.easeInOut(duration: 0.2), value: clerk.user != nil)
    }

    @ViewBuilder
    private var authenticatedRoot: some View {
        if engine.state == nil {
            NavigationStack { SetupView() }
        } else {
            NavigationStack { GameView() }
        }
    }

    @ViewBuilder
    private var unauthenticatedRoot: some View {
        ZStack {
            Theme.bgPage.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 6) {
                    Text("One Up")
                        .font(.system(size: 36, weight: .bold, design: .serif)).italic()
                        .foregroundColor(Theme.navy)
                    Text("A word game for people who know words.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.gray)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 14) {
                    ClerkKitUI.AuthView().frame(maxWidth: 400)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                .shadow(color: Theme.cardShadow, radius: 8, y: 3)
                .padding(.horizontal, 24)

                Spacer()

                Text("Sign in to save your name and play online.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Theme.gray).padding(.bottom, 20)
            }
        }
    }
}
