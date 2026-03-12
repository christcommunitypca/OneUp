//
//  SettingsAccountCardView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct SettingsAccountCardView: View {
    let userId: String?
    let savedName: String
    let currentGameLabel: String
    let isSigningOut: Bool
    let onLeaveGame: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account")
                .font(.system(size: 20, weight: .black, design: .serif))
                .italic()
                .foregroundColor(Theme.violet)

            VStack(alignment: .leading, spacing: 8) {
                if let userId, !userId.isEmpty {
                    SettingsInfoRowView(
                        title: "User ID",
                        value: shortUserId(userId)
                    )
                }

                SettingsInfoRowView(
                    title: "Saved Name",
                    value: savedName.isEmpty ? "Not set" : savedName
                )

                SettingsInfoRowView(
                    title: "Current Game",
                    value: currentGameLabel
                )
            }

            VStack(spacing: 10) {
                Button(action: onLeaveGame) {
                    Text("Leave Current Game")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Theme.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Theme.violet.opacity(0.12), lineWidth: 1.1)
                        )
                }

                Button(action: onSignOut) {
                    HStack {
                        if isSigningOut {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(isSigningOut ? "Signing Out..." : "Sign Out")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isSigningOut ? Theme.coral.opacity(0.65) : Theme.coral)
                    )
                }
                .disabled(isSigningOut)
            }
        }
        .panelStyle()
    }

    private func shortUserId(_ uid: String) -> String {
        if uid.count <= 18 { return uid }
        return "\(uid.prefix(10))...\(uid.suffix(6))"
    }
}
