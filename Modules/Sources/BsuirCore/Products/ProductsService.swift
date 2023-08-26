import Foundation
import StoreKit
import Dependencies
import Combine

public protocol ProductsService {
    var tips: [Product] { get async }
    var subscription: Product { get async throws }

    func load()
    func purchase(_ product: Product) async throws -> Bool
    func restore() async
}

// MARK: - Dependency

extension DependencyValues {
    public var productsService: ProductsService {
        get { self[ProductsServiceKey.self] }
        set { self[ProductsServiceKey.self] = newValue }
    }
}

private enum ProductsServiceKey: DependencyKey {
    public static let liveValue: any ProductsService = {
        @Dependency(\.premiumService) var premiumService
        return LiveProductsService(premiumService: premiumService)
    }()

    public static let previewValue: any ProductsService = ProductsServiceMock()
}

// MARK: - Mock

final class ProductsServiceMock: ProductsService {
    enum Failure: Error {
        case notImplemented
    }

    var tips: [Product] {
        get async { [] }
    }

    var subscription: Product {
        get async throws { throw Failure.notImplemented }
    }

    func load() {}
    func purchase(_ product: Product) async throws -> Bool { false }
    func restore() async {}
}
