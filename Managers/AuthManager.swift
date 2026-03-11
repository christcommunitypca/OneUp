import Foundation
import Combine

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isSignedIn: Bool = false
    @Published var userId: String? = nil
    @Published var playerName: String = ""
    @Published var isLoading: Bool = false

    private init() {}

    func setAuthenticatedUser(id: String?) async {
        userId = id
        isSignedIn = (id != nil)

        guard let id else {
            playerName = ""
            return
        }

        if let name = try? await SupabaseManager.shared.fetchPlayerName(clerkUserId: id) {
            playerName = name
            UserDefaults.standard.set(name, forKey: cacheKey(for: id))
        } else if let cached = UserDefaults.standard.string(forKey: cacheKey(for: id)) {
            playerName = cached
        } else {
            playerName = ""
        }
    }

    func savePlayerName(_ name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let uid = userId else { return }

        playerName = trimmed
        UserDefaults.standard.set(trimmed, forKey: cacheKey(for: uid))

        do {
            try await SupabaseManager.shared.savePlayerName(trimmed, clerkUserId: uid)
        } catch {
            // Keep local cache even if remote save fails.
        }
    }

    func signOut() async throws {
        // Current Clerk iOS docs emphasize UserButton/UserProfileView for sign-out.
        // Clear local app state for now so the project builds cleanly.
        clearLocalState()
    }

    func clearLocalState() {
        isSignedIn = false
        userId = nil
        playerName = ""
        isLoading = false
    }

    private func cacheKey(for userId: String) -> String {
        "playerName_\(userId)"
    }
}
