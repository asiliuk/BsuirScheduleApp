import Foundation
import ComposableArchitecture
import StoreKit

public struct SubscriptionFooter: Reducer {
    public struct State: Equatable {
        var isEnabled: Bool { product != nil }
        var offer: String? {
            guard let product, let subscription = product.subscription else { return nil }
            let price = product.displayPrice
            let periodName: String = {
                switch subscription.subscriptionPeriod.unit {
                case .day: return "Day"
                case .week: return "Week"
                case .month: return "Month"
                case .year: return "Year"
                @unknown default: return "--"
                }
            }()
            let period = "\(subscription.subscriptionPeriod.value) \(periodName)"
            return "\(price)\\\(period)"
        }
        var product: Product?
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
                guard let product = state.product else { return .none }
                return .fireAndForget { try await productsService.purchase(product) }
            case ._receivedProduct(let subscription):
                state.product = subscription
                return .none
            case ._failedToGetProduct:
                return .none
            }
        }
    }

    private func loadSubscriptionProducts(state: inout State) -> Effect<Action> {
        state.product = nil
        return .task {
            let subscription = try await productsService.subscription
            return ._receivedProduct(subscription)
        } catch: { _ in
            ._failedToGetProduct
        }
    }
}
