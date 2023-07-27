import Foundation
import ComposableArchitecture
import StoreKit

public struct SubscriptionFooter: Reducer {
    public enum State: Equatable {
        case loading
        case failed
        case available(Product, Product.SubscriptionInfo)

        init() {
            self = .loading
        }
    }

    public enum Action: Equatable {
        case task
        case buttonTapped

        case _failedToGetProduct
        case _receivedProduct(Product)
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return loadSubscriptionProducts(state: &state)

            case .buttonTapped:
                guard case let .available(product, _) = state else { return .none }
                return .fireAndForget { try await productsService.purchase(product) }

            case ._receivedProduct(let product):
                if let subscription = product.subscription {
                    state = .available(product, subscription)
                    return .none
                } else {
                    state = .failed
                    return .none
                }

            case ._failedToGetProduct:
                state = .failed
                return .none
            }
        }
    }

    private func loadSubscriptionProducts(state: inout State) -> Effect<Action> {
        state = .loading
        return .task {
            let subscription = try await productsService.subscription
            return ._receivedProduct(subscription)
        } catch: { _ in
            ._failedToGetProduct
        }
    }
}
