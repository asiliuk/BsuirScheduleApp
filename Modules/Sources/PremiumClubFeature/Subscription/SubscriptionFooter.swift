import Foundation
import ComposableArchitecture
import StoreKit

@Reducer
public struct SubscriptionFooter {
    @ObservableState
    public struct State: Equatable {
        enum ProductState: Equatable {
            case loading
            case failed
            case available(ProductInfo)
        }

        public struct ProductInfo: Equatable {
            var product: Product
            var subscription: Product.SubscriptionInfo
            var isEligibleForIntroOffer: Bool
        }

        var productState: ProductState = .loading
        var isPurchasing: Bool = false
    }

    public enum Action: Equatable {
        case task
        case buttonTapped

        case _failedToGetProduct
        case _received(State.ProductInfo)
        case _purchaseFinished(success: Bool, info: State.ProductInfo)
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return loadSubscriptionProducts(state: &state)

            case .buttonTapped:
                guard case let .available(info) = state.productState else { return .none }
                state.isPurchasing = true
                return .run { send in
                    try await send(._purchaseFinished(success: productsService.purchase(info.product), info: info))
                }

            case let ._received(info):
                state.productState = .available(info)
                return .none

            case ._failedToGetProduct:
                state.productState = .failed
                return .none

            case ._purchaseFinished(_, let info):
                state.isPurchasing = false
                state.productState = .available(info)
                return .none
            }
        }
    }

    private func loadSubscriptionProducts(state: inout State) -> Effect<Action> {
        state.productState = .loading
        return .run { send in
            let product = try await productsService.subscription
            guard let subscription = product.subscription else {
                await send(._failedToGetProduct)
                return
            }

            let isEligibleForIntroOffer = await subscription.isEligibleForIntroOffer
            await send(._received(.init(
                product: product,
                subscription: subscription,
                isEligibleForIntroOffer: isEligibleForIntroOffer
            )))
        } catch: { _, send in
            await send(._failedToGetProduct)
        }
    }
}
