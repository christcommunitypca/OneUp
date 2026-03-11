//
//  WordMessageBannerView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct WordMessageBannerView: View {
    let message: String

    var body: some View {
        let isError = message.localizedCaseInsensitiveContains("not") ||
            message.localizedCaseInsensitiveContains("could not") ||
            message.localizedCaseInsensitiveContains("select") ||
            message.localizedCaseInsensitiveContains("clear")

        return HStack(spacing: 8) {
            Circle()
                .fill(isError ? Color(hex: "EA580C") : Color(hex: "059669"))
                .frame(width: 7, height: 7)

            Text(message)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isError ? Color(hex: "EA580C") : Color(hex: "059669"))

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isError ? Color(hex: "FFF7ED") : Color(hex: "ECFDF5"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isError ? Color(hex: "FED7AA") : Color(hex: "A7F3D0"), lineWidth: 1)
        )
    }
}
