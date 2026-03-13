import SwiftUI

struct SetupLineupCard: View {
    @Binding var cpuPlayers: [CPUSetup]
    let canAddCPU: Bool
    let onAddCPU: () -> Void
    let onRemoveCPU: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Lineup")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .italic()
                    .foregroundColor(Theme.navy)

                Spacer()

                Button(action: onAddCPU) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))

                        Text("CPU")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(canAddCPU ? Theme.navy : Theme.gray)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Theme.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!canAddCPU)
            }

            if cpuPlayers.isEmpty {
                Text("No CPU opponents added")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.gray)
            } else {
                VStack(spacing: 8) {
                    ForEach($cpuPlayers) { $cpu in
                        SetupCPULineupRow(
                            cpu: $cpu,
                            onRemove: { onRemoveCPU(cpu.id) }
                        )
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.border, lineWidth: 1)
        )
        .shadow(color: Theme.cardShadow, radius: 3, y: 1)
    }
}

private struct SetupCPULineupRow: View {
    @Binding var cpu: CPUSetup
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "cpu")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Theme.slate)

            Text(cpu.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            Menu {
                ForEach(CPUDifficulty.allCases) { level in
                    Button(level.rawValue) {
                        cpu.difficulty = level
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(cpu.difficulty.shortLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.navy)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(Theme.navy)
                }
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Theme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Theme.gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .frame(height: 38)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Theme.bgSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}
