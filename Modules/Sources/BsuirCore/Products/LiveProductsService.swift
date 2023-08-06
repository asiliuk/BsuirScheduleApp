import Foundation
import StoreKit
import os.log
import Combine

final class LiveProductsService {
    private enum SubscriptionError: Error {
        case noSubscriptionLoaded
    }

    private var purchasedProductIds: Set<String> = []
    private var updatesTask: Task<Void, Never>?
    private var _tips: [Product] = []
    private var _subscriptions: [Product] = []
    private let premiumService: PremiumService

    init(premiumService: PremiumService) {
        self.premiumService = premiumService
    }

    deinit {
        updatesTask?.cancel()
    }

    private func loadProductsIfNeeded() async {
        guard _tips.isEmpty || _subscriptions.isEmpty else {
            return
        }

        let tipsIds = TipID.allCases.map(\.rawValue)
        let subscriptionIds = SubscriptionID.allCases.map(\.rawValue)
        do {
            let products = try await Product.products(for: tipsIds + subscriptionIds)
            _tips = tipsIds.compactMap { id in products.first(where: { $0.id == id }) }
            _subscriptions = subscriptionIds.compactMap { id in products.first(where: { $0.id == id }) }
        } catch {
            os_log(.error, log: .products, "Failed to fetch products: \(error.localizedDescription)")
        }
    }

    private func listenForUpdates() {
        updatesTask?.cancel()
        updatesTask = Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard case let .verified(transaction) = result else { continue }
                os_log(.info, log: .products, "Received transaction update")
                await transaction.finish()
                self?.updatePurchasedProducts(for: transaction)
            }
        }
    }

    private func updatePurchasedProductsWithCurrentEntitlements() async {
        os_log(.info, log: .products, "Start restoring currentEntitlements")
        defer { os_log(.info, log: .products, "Finished restoring currentEntitlements") }

        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            updatePurchasedProducts(for: transaction)
        }
        updatePremiumStateIfNeeded()
    }

    private func updatePurchasedProducts(for transaction: Transaction) {
        if transaction.revocationDate == nil {
            os_log(.info, log: .products, "Adding product to purchased: \(transaction.productID)")
            purchasedProductIds.insert(transaction.productID)
        } else {
            os_log(.info, log: .products, "Removing product from purchased: \(transaction.productID)")
            purchasedProductIds.remove(transaction.productID)
        }
        updatePremiumStateIfNeeded()
    }

    private func updatePremiumStateIfNeeded() {
        let isCurrentlyPremium = purchasedProductIds.contains(SubscriptionID.yearly.rawValue)
        if isCurrentlyPremium != premiumService.isCurrentlyPremium {
            os_log(.info, log: .products, "Updating isCurrentlyPremium: \(isCurrentlyPremium)")
            premiumService.isCurrentlyPremium = isCurrentlyPremium
        }
    }
}

// MARK: - ProductsService

extension LiveProductsService: ProductsService {
    var tips: [Product] {
        get async {
            await loadProductsIfNeeded()
            return _tips
        }
    }

    var subscription: Product {
        get async throws {
            await loadProductsIfNeeded()
            guard let subscription = _subscriptions.first else { throw SubscriptionError.noSubscriptionLoaded }
            return subscription
        }
    }

    func load() async {
        await loadProductsIfNeeded()
        await updatePurchasedProductsWithCurrentEntitlements()
        listenForUpdates()
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            os_log(.info, log: .products, "Purchase succeed: \(transaction.productID)")
            await transaction.finish()
            updatePurchasedProducts(for: transaction)
        case let .success(.unverified(transaction, error)):
            os_log(.info, log: .products, "Purchase failed: \(transaction.productID) \(error.localizedDescription)")
        case .pending:
            os_log(.info, log: .products, "Purchase pending: \(product.id)")
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            os_log(.error, log: .products, "Failed to restore purchases: \(error.localizedDescription)")
        }
    }
}

// MARK: - ID

private extension LiveProductsService {
    enum TipID: String, CaseIterable {
        case small = "com.saute.bsuir_schedule.tips.small"
        case medium = "com.saute.bsuir_schedule.tips.medium"
        case large = "com.saute.bsuir_schedule.tips.large"
    }

    enum SubscriptionID: String, CaseIterable {
        case yearly = "com.saute.bsuir_schedule.premium_club.yearly"
    }
}

// MARK: - Helpers

private extension OSLog {
    static let products = bsuirSchedule(category: "Products")
}
