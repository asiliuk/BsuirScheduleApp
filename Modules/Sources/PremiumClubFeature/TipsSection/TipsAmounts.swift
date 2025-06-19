import StoreKit
import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct TipsAmounts {
    @ObservableState
    public struct State {
        var amounts: IdentifiedArrayOf<TipsAmount.State> = []

        init(products: [Product] = []) {
            amounts = []
            for product in products where product.type == .consumable {
                let tipsAmount = TipsAmount.State(product: product)
                amounts.append(tipsAmount)
            }
        }
    }

    public enum Action {
        case amounts(IdentifiedActionOf<TipsAmount>)
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .forEach(\.amounts, action: \.amounts) {
                TipsAmount()
            }
    }
}

// MARK: - TipsAmount

@Reducer
public struct TipsAmount {
    @ObservableState
    public struct State: Identifiable {
        public var id: String { product.id }
        var confettiCounter: Int = 0
        var product: Product
        var title: TextState { TextState(LocalizedStringKey(product.id)) }
        var amount: TextState { TextState(product.displayPrice) }
    }

    public enum Action {
        case buyButtonTapped
        case _productPurchased(success: Bool)
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .buyButtonTapped:
                return .run { [product = state.product] send in
                    let success = try await productsService.purchase(product)
                    await send(._productPurchased(success: success))
                }
            case ._productPurchased(true):
                state.confettiCounter += 1
                return .none
            case ._productPurchased(false):
                return .none
            }
        }
    }
}
