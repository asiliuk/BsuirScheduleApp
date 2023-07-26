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

        case _failedToGetProduct
        case _receivedProduct(Product)
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return loadSubscriptionProducts(state: &state)
            case ._receivedProduct(let subscription):
                state.product = subscription
                return .none
            case ._failedToGetProduct:
                print("Failed to fetch subscription")
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

import SwiftUI

struct SubscriptionFooterView: View {
    let store: StoreOf<SubscriptionFooter>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {

            } label: {
                if let offer = viewStore.offer {
                    VStack {
                        Text("Buy premium pass")
                            .font(.subheadline)
                        Text(offer)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .progressViewStyle(.circular)
                }
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .disabled(!viewStore.isEnabled)
            .task { await viewStore.send(.task).finish() }
        }
    }
}
