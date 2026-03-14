import SwiftUI
import StoreKit

struct SupportView: View {
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var message: String?

    private let productIDs = [
        "com.oneup.tip.coffee",
        "com.oneup.tip.lunch",
        "com.oneup.tip.keep_running"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Support One Up")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .italic()
                    .foregroundColor(Theme.navy)

                Text("If you enjoy the game, you can leave a tip to support future updates.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                } else if sortedProducts.isEmpty {
                    emptyStateCard
                } else {
                    ForEach(sortedProducts, id: \.id) { product in
                        Button {
                            Task { await buy(product) }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.pink)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(title(for: product.id))
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.navy)

                                    Text(subtitle(for: product.id))
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(Theme.textSecondary)
                                }

                                Spacer()

                                Text(product.displayPrice)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Theme.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let message {
                    Text(message)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .background(Theme.bgPage.ignoresSafeArea())
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadProducts()
        }
    }

    private var sortedProducts: [Product] {
        products.sorted { lhs, rhs in
            productIDs.firstIndex(of: lhs.id)! < productIDs.firstIndex(of: rhs.id)!
        }
    }

    private var emptyStateCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Support options are not available yet.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.navy)

            Text("If this is TestFlight, your tip items may still need a moment to appear. You can come back here later and try again.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            if products.isEmpty {
                message = "No support options are showing yet."
            }
        } catch {
            message = "Could not load support options."
        }
        isLoading = false
    }

    private func buy(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    message = "Thank you for supporting One Up."
                case .unverified(_, _):
                    message = "Purchase completed, but could not be verified."
                }

            case .pending:
                message = "Purchase is pending approval."

            case .userCancelled:
                break

            @unknown default:
                message = "Purchase did not complete."
            }
        } catch {
            message = "Purchase failed. Please try again."
        }
    }

    private func title(for id: String) -> String {
        switch id {
        case "com.oneup.tip.coffee":
            return "Buy Rick a Coffee"
        case "com.oneup.tip.lunch":
            return "Buy Rick Lunch"
        case "com.oneup.tip.keep_running":
            return "Keep One Up Running"
        default:
            return "Support One Up"
        }
    }

    private func subtitle(for id: String) -> String {
        switch id {
        case "com.oneup.tip.coffee":
            return "A small thank-you"
        case "com.oneup.tip.lunch":
            return "A generous tip"
        case "com.oneup.tip.keep_running":
            return "Help fund updates and polish"
        default:
            return ""
        }
    }
}
