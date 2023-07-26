import Foundation
import StoreKit
import Dependencies
import Combine

public protocol ProductsService {
    var isCurrentlyPremium: Bool { get }
    var isPremium: AnyPublisher<Bool, Never> { get }

    var tips: [Product] { get async }
    var subscription: Product { get async throws }

    func load() async
    func purchase(_ product: Product) async throws
}

// MARK: - Dependency

extension DependencyValues {
    public var productsService: ProductsService {
        get { self[ProductsServiceKey.self] }
        set { self[ProductsServiceKey.self] = newValue }
    }
}

private enum ProductsServiceKey: DependencyKey {
    public static let liveValue: any ProductsService = LiveProductsService()
}
