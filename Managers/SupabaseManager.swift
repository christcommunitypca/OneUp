import Foundation
import Supabase

@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient
    private var gameChannel: RealtimeChannelV2?

    private init() {
        client = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
    }

    private struct PlayerProfileUpsert: Encodable {
        let clerk_user_id: String
        let display_name: String
        let updated_at: String
    }

    private struct PlayerProfileRow: Decodable {
        let display_name: String
    }

    private struct GameInsertRow: Encodable {
        let id: UUID
        let invite_code: String
        let state: GameState
        let created_at: String
        let updated_at: String
    }

    private struct GameUpdateRow: Encodable {
        let state: GameState
        let updated_at: String
    }

    private struct GameStateRow: Decodable {
        let state: GameState
    }

    func savePlayerName(_ name: String, clerkUserId: String) async throws {
        let row = PlayerProfileUpsert(
            clerk_user_id: clerkUserId,
            display_name: name,
            updated_at: isoNow()
        )

        try await client
            .from("player_profiles")
            .upsert(row, onConflict: "clerk_user_id")
            .execute()
    }

    func fetchPlayerName(clerkUserId: String) async throws -> String? {
        do {
            let row: PlayerProfileRow = try await client
                .from("player_profiles")
                .select("display_name")
                .eq("clerk_user_id", value: clerkUserId)
                .single()
                .execute()
                .value

            return row.display_name
        } catch {
            return nil
        }
    }

    func createGame(state: GameState) async throws -> String {
        let code = generateInviteCode()

        let row = GameInsertRow(
            id: state.id,
            invite_code: code,
            state: state,
            created_at: isoNow(),
            updated_at: isoNow()
        )

        try await client
            .from("games")
            .insert(row)
            .execute()

        return code
    }

    func loadGame(inviteCode: String) async throws -> GameState? {
        do {
            let row: GameStateRow = try await client
                .from("games")
                .select("state")
                .eq("invite_code", value: inviteCode.uppercased())
                .single()
                .execute()
                .value

            return row.state
        } catch {
            return nil
        }
    }

    func updateGame(state: GameState) async throws {
        let row = GameUpdateRow(
            state: state,
            updated_at: isoNow()
        )

        try await client
            .from("games")
            .update(row)
            .eq("id", value: state.id.uuidString)
            .execute()
    }

    func subscribeToGame(id: UUID, onChange: @escaping (GameState) -> Void) async {
        await unsubscribeFromGame()

        let channel = client.channel("game-\(id.uuidString)")

        _ = channel.onPostgresChange(
            AnyAction.self,
            schema: "public",
            table: "games"
        ) { change in
            let recordObject: [String: Any]

            switch change {
            case .insert(let action):
                recordObject = action.record
            case .update(let action):
                recordObject = action.record
            case .delete:
                return
            }

            Task { @MainActor in
                guard let idString = recordObject["id"] as? String,
                      let recordId = UUID(uuidString: idString),
                      recordId == id,
                      let stateObject = recordObject["state"] else {
                    return
                }

                do {
                    let stateData = try JSONSerialization.data(withJSONObject: stateObject)
                    let decodedState = try JSONDecoder().decode(GameState.self, from: stateData)
                    onChange(decodedState)
                } catch {
                    // Ignore malformed realtime payloads
                }
            }
        }

        do {
            try await channel.subscribeWithError()
            gameChannel = channel
        } catch {
            gameChannel = nil
        }
    }

    func unsubscribeFromGame() async {
        if let channel = gameChannel {
            await client.removeChannel(channel)
        }
        gameChannel = nil
    }

    private func generateInviteCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).compactMap { _ in chars.randomElement() })
    }

    private func isoNow() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}
