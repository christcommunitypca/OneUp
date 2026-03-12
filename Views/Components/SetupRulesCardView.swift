import SwiftUI

struct SetupRulesCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SetupSectionTitleView("How to Play")
            SetupSummaryLineView("Select a letter from your hand, then tap where it goes on the word.")
            SetupSummaryLineView("First play uses letters in the order you tapped them.")
            SetupSummaryLineView("After placing one, select another or press Play.")
            SetupSummaryLineView("Selecting multiple cards before choosing an action leads to discard.")
        }
        .setupCardStyle()
    }
}
