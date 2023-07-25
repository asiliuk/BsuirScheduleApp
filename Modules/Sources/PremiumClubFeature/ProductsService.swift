import Foundation
import StoreKit
import Dependencies
import os.log
import BsuirCore

public struct ProductsService {
    public var listenToUpdates: () async -> Void
    public var tips: () async throws -> [Product]
    public var subscription: () async throws -> Product?
}

// MARK: - Dependency

extension DependencyValues {
    public var productsService: ProductsService {
        get { self[ProductsService.self] }
        set { self[ProductsService.self] = newValue }
    }
}

extension ProductsService: DependencyKey {
    private static let products = OSLog.bsuirSchedule(category: "Products")

    public static let liveValue = ProductsService(
        listenToUpdates: {
            for await result in Transaction.updates {
                switch result {
                case .unverified(let transaction, let result):
                    os_log(.info, log: .products, "Transaction unverified: \(transaction.productID) \(result)")
                case .verified(let transaction):
                    os_log(.info, log: .products, "Transaction verified: \(transaction.productID)")
                }
            }
        },
        tips: {
            let ids = TipID.allCases.map(\.rawValue)
            return try await Product.products(for: ids)
        },
        subscription: {
            try await Product.products(for: [SubscriptionID.yearly.rawValue]).last
        }
    )
}

private extension OSLog {
    static let products = bsuirSchedule(category: "Products")
}

// MARK: - ID

private extension ProductsService {
    enum TipID: String, CaseIterable {
        case small = "com.saute.bsuir_schedule.tips.small"
        case medium = "com.saute.bsuir_schedule.tips.medium"
        case large = "com.saute.bsuir_schedule.tips.large"
    }

    enum SubscriptionID: String, CaseIterable {
        case yearly = "com.saute.bsuir_schedule.premium_club.yearly"
    }
}
