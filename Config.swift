import Foundation

enum Config {
    // ── Clerk ──────────────────────────────────────────────
    // Get from: https://dashboard.clerk.com → API Keys
    static let clerkPublishableKey = "pk_test_cmVhbC13YWhvby04My5jbGVyay5hY2NvdW50cy5kZXYk"

    // ── Supabase ───────────────────────────────────────────
    // Get from: https://supabase.com → Project Settings → API
    static let supabaseURL = URL(string: "https://kzktfsxfjqqiocfmtawl.supabase.co")!
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6a3Rmc3hmanFxaW9jZm10YXdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxNjU0OTEsImV4cCI6MjA4ODc0MTQ5MX0._FpnKIbinLy_L_c-gkFcURsKpnb6-wINDjJ4L9rmmNE"

    // ── Dictionary API ────────────────────────────────────
    static let dictionaryBaseURL = "https://api.dictionaryapi.dev/api/v2/entries/en/"

    // ── Game ──────────────────────────────────────────────
    static let handSize = 7
    static let winScore = 20
    static let cpuThinkTimeSeconds: Double = 1.4
}
