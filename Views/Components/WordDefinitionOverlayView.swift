import SwiftUI

struct WordDefinitionOverlayView: View {
    let word: String
    let onClose: () -> Void

    @State private var lookupState: LookupState = .loading

    var body: some View {
        ZStack {
            Color.black.opacity(0.34)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                Divider()
                    .overlay(Theme.border)

                content
            }
            .frame(maxWidth: 560)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.border, lineWidth: 1)
            )
            .padding(.horizontal, 18)
            .shadow(color: Color.black.opacity(0.16), radius: 18, x: 0, y: 10)
        }
        .task(id: word) {
            await loadDefinition()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Definition")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.gray)
                    .textCase(.uppercase)
                    .kerning(0.8)

                Text(word.uppercased())
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Theme.navy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)

            Button(action: onClose) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                    Text("Close")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Theme.navy)
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Theme.bgSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Theme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
    }

    @ViewBuilder
    private var content: some View {
        switch lookupState {
        case .loading:
            VStack(spacing: 12) {
                ProgressView()
                    .tint(Theme.navy)
                Text("Looking up definition...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .padding(16)

        case .notFound:
            infoBody(
                title: "No online definition found",
                message: "Words are verified by a local database. This specific word was not found in the online dictionary service.",
                symbol: "book.closed"
            )

        case .unavailable:
            infoBody(
                title: "Dictionary unavailable",
                message: "We couldn't reach the online dictionary right now. Please try again in a moment.",
                symbol: "wifi.exclamationmark"
            )

        case .found(let items):
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Theme.navy)

                                VStack(alignment: .leading, spacing: 6) {
                                    if let partOfSpeech = item.partOfSpeech,
                                       !partOfSpeech.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text(partOfSpeech.capitalized)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(Theme.navy)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule(style: .continuous)
                                                    .fill(Theme.navyLight)
                                            )
                                    }

                                    Text(item.definition)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Theme.text)
                                        .fixedSize(horizontal: false, vertical: true)

                                    if let example = item.example,
                                       !example.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("Example: \(example)")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.textSecondary)
                                            .italic()
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Theme.bgSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Theme.border, lineWidth: 1)
                        )
                    }
                }
                .padding(16)
            }
            .frame(minHeight: 220, maxHeight: 420)
        }
    }

    private func infoBody(title: String, message: String, symbol: String) -> some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(Theme.navy)

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.text)

            Text(message)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(20)
    }

    private func loadDefinition() async {
        lookupState = .loading
        let result = await DictionaryService.lookupDefinition(word)
        switch result {
        case .found(let items):
            lookupState = .found(items)
        case .notFound:
            lookupState = .notFound
        case .unavailable:
            lookupState = .unavailable
        }
    }
}

private enum LookupState {
    case loading
    case found([DictionaryDefinitionItem])
    case notFound
    case unavailable
}
