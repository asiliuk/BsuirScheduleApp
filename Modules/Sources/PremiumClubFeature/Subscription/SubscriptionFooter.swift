import Foundation
import ComposableArchitecture
import StoreKit

public struct SubscriptionFooter: Reducer {
    public enum State: Equatable {
        case loading
        case failed
        case available(Product, Product.SubscriptionInfo, isEligibleForIntroOffer: Bool)

        init() {
            self = .loading
        }
    }

    public enum Action: Equatable {
        case task
        case buttonTapped

        case _failedToGetProduct
        case _received(product: Product, subscription: Product.SubscriptionInfo, isEligibleForIntroOffer: Bool)
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return loadSubscriptionProducts(state: &state)

            case .buttonTapped:
                guard case let .available(product, _, _) = state else { return .none }
                return .run { _ in try await productsService.purchase(product) }

            case let ._received(product, subscription, isEligibleForIntroOffer):
                state = .available(product, subscription, isEligibleForIntroOffer: isEligibleForIntroOffer)
                return .none

            case ._failedToGetProduct:
                state = .failed
                return .none
            }
        }
    }

    private func loadSubscriptionProducts(state: inout State) -> Effect<Action> {
        state = .loading
        return .run { send in
            let product = try await productsService.subscription
            guard let subscription = product.subscription else {
                await send(._failedToGetProduct)
                return
            }

            let isEligibleForIntroOffer = await subscription.isEligibleForIntroOffer
            await send(._received(
                product: product,
                subscription: subscription,
                isEligibleForIntroOffer: isEligibleForIntroOffer
            ))
        } catch: { _, send in
            await send(._failedToGetProduct)
        }
    }
}
