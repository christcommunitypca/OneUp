import SwiftUI

struct ContentView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        Group {
            if engine.state == nil {
                NavigationStack { SetupView() }
            } else {
                NavigationStack { GameView() }
            }
        }
    }
}
