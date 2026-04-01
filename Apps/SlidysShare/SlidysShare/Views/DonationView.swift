import SwiftUI
import StoreKit

private enum TipProduct: String, CaseIterable {
    case small = "com.sugiy.slidysshare.tip.small"
    case medium = "com.sugiy.slidysshare.tip.medium"
    case large = "com.sugiy.slidysshare.tip.large"

    var displayName: String {
        switch self {
        case .small: String(localized: "サポート（小）")
        case .medium: String(localized: "サポート（中）")
        case .large: String(localized: "サポート（大）")
        }
    }

    var iconName: String {
        switch self {
        case .small: "heart"
        case .medium: "heart.circle"
        case .large: "heart.circle.fill"
        }
    }
}

struct DonationView: View {
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var showThankYou = false

    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            } else if products.isEmpty {
                ContentUnavailableView("商品が見つかりません", systemImage: "heart.slash", description: Text("現在サポートアイテムを取得できません"))
            } else {
                ForEach(products, id: \.id) { product in
                    if let tip = TipProduct(rawValue: product.id) {
                        #if os(visionOS)
                        ProductView(id: product.id)
                        #else
                        HStack {
                            Image(systemName: tip.iconName)
                                .font(.title2)
                                .foregroundStyle(.tint)
                                .frame(width: 32)
                            Text(tip.displayName)
                            Spacer()
                            Button {
                                Task { await purchase(product) }
                            } label: {
                                Text(product.displayPrice)
                                    .font(.subheadline.bold())
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                        }
                        .padding(.vertical, 4)
                        #endif
                    }
                }
            }
        }
        .navigationTitle("開発者をサポート")
        .task {
            let fetched = (try? await Product.products(for: TipProduct.allCases.map(\.rawValue))) ?? []
            products = fetched.sorted { $0.price < $1.price }
            isLoading = false
        }
        .alert("ありがとうございます！", isPresented: $showThankYou) {
            Button("OK") {}
        } message: {
            Text("サポートいただきありがとうございます。開発の励みになります！")
        }
    }

    #if !os(visionOS)
    private func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    showThankYou = true
                }
            default:
                break
            }
        } catch {
            // Purchase cancelled or failed
        }
    }
    #endif
}

#if DEBUG
#Preview {
    NavigationStack {
        DonationView()
    }
}
#endif
