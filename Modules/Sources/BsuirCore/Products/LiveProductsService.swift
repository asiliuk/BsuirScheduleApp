import Foundation
import StoreKit
import OSLog
import Combine
import ComposableArchitecture

final class LiveProductsService {
    private enum SubscriptionError: Error {
        case noSubscriptionLoaded
    }

    private var purchasedProductIds: Set<String> = []
    private var loadTask: Task<Void, Never>?
    private var updatesTask: Task<Void, Never>?
    private var _tips: [Product] = []
    private var _subscriptions: [Product] = []
    @Shared(.isPremiumUser) private var isPremiumUser
    private let widgetService: WidgetService

    init(widgetService: WidgetService) {
        self.widgetService = widgetService
    }

    deinit {
        updatesTask?.cancel()
        loadTask?.cancel()
    }

    private func loadInitialData() {
        Task(priority: .userInitiated) {
            await loadProductsIfNeeded()
            await updatePurchasedProductsWithCurrentEntitlements()
        }
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
            Logger.products.error("Failed to fetch products: \(error.localizedDescription)")
        }
    }

    private func listenForUpdates() {
        updatesTask?.cancel()
        updatesTask = Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard case let .verified(transaction) = result else { continue }
                Logger.products.info("Received transaction update")
                await transaction.finish()
                self?.updatePurchasedProducts(for: transaction)
            }
        }
    }

    private func updatePurchasedProductsWithCurrentEntitlements() async {
        Logger.products.info("Start restoring currentEntitlements")
        defer { Logger.products.info("Finished restoring currentEntitlements") }

        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            updatePurchasedProducts(for: transaction)
        }
        updatePremiumStateIfNeeded()
    }

    private func updatePurchasedProducts(for transaction: Transaction) {
        if transaction.revocationDate == nil {
            Logger.products.info("Adding product to purchased: \(transaction.productID)")
            purchasedProductIds.insert(transaction.productID)
        } else {
            Logger.products.info("Removing product from purchased: \(transaction.productID)")
            purchasedProductIds.remove(transaction.productID)
        }
        updatePremiumStateIfNeeded()
    }

    private func updatePremiumStateIfNeeded() {
        let isCurrentlyPremium = purchasedProductIds.contains(SubscriptionID.yearly.rawValue)
        DispatchQueue.main.async { [$isPremiumUser, widgetService] in
            if isCurrentlyPremium != $isPremiumUser.wrappedValue {
                Logger.products.info("Updating isCurrentlyPremium: \(isCurrentlyPremium)")
                $isPremiumUser.withLock { $0 = isCurrentlyPremium }
                widgetService.reloadAll()
            }
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

    var subscriptionStatus: Product.SubscriptionInfo.Status? {
        get async {
            let result = await Transaction.currentEntitlement(for: SubscriptionID.yearly.rawValue)
            guard case let .verified(transaction) = result else { return nil }
            return await transaction.subscriptionStatus
        }
    }

    func load() {
        loadInitialData()
        listenForUpdates()
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            Logger.products.info("Purchase succeed: \(transaction.productID)")
            await transaction.finish()
            updatePurchasedProducts(for: transaction)
            return true
        case let .success(.unverified(transaction, error)):
            Logger.products.info("Purchase failed: \(transaction.productID) \(error.localizedDescription)")
            return false
        case .pending:
            Logger.products.info("Purchase pending: \(product.id)")
            return false
        case .userCancelled:
            return false
        @unknown default:
            return false
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            Logger.products.error("Failed to restore purchases: \(error.localizedDescription)")
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

private extension Logger {
    static let products = bsuirSchedule(category: "Products")
}
