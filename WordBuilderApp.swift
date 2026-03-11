import SwiftUI
import ClerkKit

@main
struct WordBuilderApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var gameEngine = GameEngine()

    init() {
        Clerk.configure(publishableKey: Config.clerkPublishableKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(Clerk.shared)
                .environmentObject(authManager)
                .environmentObject(gameEngine)
        }
    }
}
