//
//  WordAreaHeaderView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct WordAreaHeaderView: View {
    let statusTitle: String
    let statusSubtitle: String
    let displayedPoints: Int?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(statusTitle)
                    .font(.system(size: 17, weight: .black, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "6E4DD8"))

                Text(statusSubtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "6B7280"))
            }

            Spacer()

            if let points = displayedPoints {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(points)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color(hex: "D97706"))
                    Text(points == 1 ? "point" : "points")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "FEF3C7"))
                )
            }
        }
    }
}
