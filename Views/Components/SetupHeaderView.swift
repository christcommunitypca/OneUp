//
//  SetupHeaderView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct SetupHeaderView: View {
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Word Builder")
                    .font(.system(size: 26, weight: .black, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "6E4DD8"))

                Text("Set up a cleaner game.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "6B7280"))
            }

            Spacer()

            Button(action: onClose) {
                Text("Close")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}
