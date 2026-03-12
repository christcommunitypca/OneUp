//
//  SetupRulesCardView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct SetupRulesCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SetupSectionTitleView("How Play Works")

            SetupSummaryLineView("Select a card, then tap where it goes.")
            SetupSummaryLineView("First play uses the order you tapped the letters.")
            SetupSummaryLineView("After placing one, you can add another or press Play.")
            SetupSummaryLineView("If you select multiple cards before choosing an action, discard becomes the path.")
        }
        .setupCardStyle()
    }
}
