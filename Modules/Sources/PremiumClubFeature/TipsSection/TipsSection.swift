import Foundation
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI
import Favorites
import StoreKit

@Reducer
public struct TipsSection {
    public struct State: Equatable {
        // TODO: Try to use @LoadableState here
        var failedToFetchProducts: Bool = false
        var isLoadingProducts: Bool = false
        var tipsAmounts: IdentifiedArrayOf<TipsAmount.State> = []
        var freeLove: FreeLove.State = .init()
    }

    public enum Action: Equatable {
        case task
        case reloadTips
        case tipsAmounts(IdentifiedActionOf<TipsAmount>)
        case freeLove(FreeLove.Action)

        case _failedToGetProducts
        case _receivedProducts([Product])
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return loadTipsProducts(state: &state)

            case .reloadTips:
                return loadTipsProducts(state: &state)

            case let ._receivedProducts(products):
                state.isLoadingProducts = false
                state.failedToFetchProducts = false
                state.tipsAmounts = []
                for product in products where product.type == .consumable {
                    let tipsAmount = TipsAmount.State(product: product)
                    state.tipsAmounts.append(tipsAmount)
                }
                return .none

            case ._failedToGetProducts:
                state.isLoadingProducts = false
                state.failedToFetchProducts = true
                return .none

            case .freeLove, .tipsAmounts:
                return .none
            }
        }
        .forEach(\.tipsAmounts, action: \.tipsAmounts) {
            TipsAmount()
        }

        Scope(state: \.freeLove, action: \.freeLove) {
            FreeLove()
        }
    }

    private func loadTipsProducts(state: inout State) -> Effect<Action> {
        state.isLoadingProducts = true
        state.failedToFetchProducts = false
        return .run { send in
            let products = await productsService.tips
            await send(._receivedProducts(products))
        } catch: { _, send in
            await send(._failedToGetProducts)
        }
    }
}

@Reducer
public struct FreeLove {
    public struct State: Equatable {
        var highScore: Int = {
            @Dependency(\.favorites.freeLoveHighScore) var freeLoveHighScore
            return freeLoveHighScore
        }()
        var counter: Int = 0
        var confettiCounter: Int = 0
    }

    public enum Action: Equatable {
        case loveButtonTapped
        case _resetCounter
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.favorites) var favorites

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loveButtonTapped:
                state.counter += 1
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(._resetCounter)
                }
                .animation(.easeIn)
                .cancellable(id: CancelID.reset, cancelInFlight: true)

            case ._resetCounter:
                let score = state.counter
                state.counter = 0
                guard score > state.highScore else { return .none }
                state.highScore = score
                state.confettiCounter += 1
                return .run { _ in favorites.freeLoveHighScore = score }
            }
        }
    }

    private enum CancelID {
        case reset
    }
}

@Reducer
public struct TipsAmount {
    public struct State: Equatable, Identifiable {
        public var id: String { product.id }
        var confettiCounter: Int = 0
        var product: Product
        var title: TextState { TextState(LocalizedStringKey(product.id)) }
        var amount: TextState { TextState(product.displayPrice) }
    }

    public enum Action: Equatable {
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
