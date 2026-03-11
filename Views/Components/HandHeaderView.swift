//
//  HandHeaderView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct HandHeaderView: View {
    let remainingSeconds: Int?

    var body: some View {
        HStack {
            Text("Your Hand")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            Spacer()

            if let seconds = remainingSeconds {
                Text("\(seconds)s")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(seconds <= 5 ? Color(hex: "C2410C") : Color(hex: "6E4DD8"))
                    .padding(.horizontal, 9)
                    .frame(height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(seconds <= 5 ? Color(hex: "FFF7ED") : Color(hex: "F5F3FF"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(seconds <= 5 ? Color(hex: "FED7AA") : Color(hex: "DDD6FE"), lineWidth: 1)
                    )
            }
        }
    }
}
