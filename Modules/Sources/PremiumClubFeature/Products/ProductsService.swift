import Foundation
import StoreKit
import Dependencies

public protocol ProductsService {
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

enum ProductsServiceKey: DependencyKey {
    public static let liveValue: ProductsService = LiveProductsService()
}
