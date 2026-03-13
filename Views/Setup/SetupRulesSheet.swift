//
//  SetupRulesSheet.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/12/26.
//

import SwiftUI

struct SetupRulesSheet: View {
    @Binding var isPresented: Bool
    let winScore: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to Play")
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .italic()
                        .foregroundColor(Theme.navy)

                    ruleLine("Select letters from your hand to spell or extend a word.")
                    ruleLine("Add or swap letters each turn.")
                    ruleLine("Discard to draw new letters.")
                    ruleLine("Pass when you cannot play.")

                    Text("Scoring")
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .italic()
                        .foregroundColor(Theme.navy)
                        .padding(.top, 6)

                    ruleLine("Letters 1–4: one point each.")
                    ruleLine("Letters 5 and beyond: two points each.")
                    ruleLine("Points go to the last player to add letters when all others pass.")
                    ruleLine("First to \(winScore) points wins.")
                }
                .padding(20)
            }
            .background(Theme.bgPage.ignoresSafeArea())
            .navigationTitle("Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.navy)
                }
            }
        }
    }

    private func ruleLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("–")
                .foregroundColor(Theme.navy)
                .font(.system(size: 13))

            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.textSecondary)

            Spacer()
        }
    }
}
