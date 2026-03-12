//
//  SettingsProfileCardView.swift
//  WordBuilder
//
//  Created by Rick Hutchinson on 3/11/26.
//

import SwiftUI

struct SettingsProfileCardView: View {
    @Binding var editedName: String

    let isSaving: Bool
    let canSaveName: Bool
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Profile")
                .font(.system(size: 20, weight: .black, design: .serif))
                .italic()
                .foregroundColor(Theme.violet)

            VStack(alignment: .leading, spacing: 8) {
                Text("Display Name")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.gray)

                TextField("Your name", text: $editedName)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Theme.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.violet.opacity(0.10), lineWidth: 1.1)
                    )

                Text("This name appears in local and online games.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.gray)
            }

            Button(action: onSave) {
                HStack {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(isSaving ? "Saving..." : "Save Name")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(canSaveName ? Theme.violet : Theme.lightGray)
                )
            }
            .disabled(!canSaveName || isSaving)
        }
        .panelStyle()
    }
}
