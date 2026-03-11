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
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Word Builder")
                    .font(.system(size: 24, weight: .black, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "6E4DD8"))

                HStack(spacing: 6) {
                    Text(isMyTurn ? "Your turn" : "\(state.currentPlayer.displayName)'s turn")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "4B5563"))

                    if let remainingSeconds {
                        Text("• \(remainingSeconds)s")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(remainingSeconds <= 5 ? Color(hex: "C2410C") : Color(hex: "6E4DD8"))
                    }
                }
            }

            Spacer()

            HStack(spacing: 8) {
                GameHeaderButton(title: "?", action: onHelp)
                GameHeaderButton(title: "New Game", action: onNewGame)
                GameHeaderButton(title: "Settings", action: onSettings)
            }
        }
    }
}

private struct GameHeaderButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
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
