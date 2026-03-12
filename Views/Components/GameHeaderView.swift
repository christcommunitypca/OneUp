//
//  GameHeaderView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct GameHeaderView: View {
    let state: GameState
    let isMyTurn: Bool
    let remainingSeconds: Int?
    let onHelp: () -> Void
    let onNewGame: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("One Up")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: "2563EB"))
                .frame(maxWidth: .infinity)

            Text("Add a letter. Steal the lead!")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "60A5FA"))
                .frame(maxWidth: .infinity)

            HStack(spacing: 14) {
                GameHeaderIconButton(systemName: "house", action: onNewGame)
                GameHeaderIconButton(systemName: "questionmark.circle", action: onHelp)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct GameHeaderIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "1E3A8A"))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(hex: "D6EAFE"), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
