import Foundation
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI
import Favorites
import StoreKit

private enum TipsProductIdentifier: String, CaseIterable {
    case small = "com.saute.bsuir_schedule.tips.small"
    case medium = "com.saute.bsuir_schedule.tips.medium"
    case large = "com.saute.bsuir_schedule.tips.large"
}

public struct TipsSection: Reducer {
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
        case tipsAmount(id: TipsAmount.State.ID, action: TipsAmount.Action)
        case freeLove(FreeLove.Action)

        case _failedToGetProducts
        case _receivedProducts([Product])

        case _failedToPurchase(Product)
        case _purchaseProductCancelled
        case _purchaseProductPending
        case _purchaseProductSucceed(Product, VerificationResult<StoreKit.Transaction>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return loadTipsProducts(state: &state)
            case .reloadTips:
                return loadTipsProducts(state: &state)
            case let .tipsAmount(id, action: .buyButtonTapped):
                guard let product = state.tipsAmounts[id: id]?.product else {
                    return .none
                }
                return .task {
                    // TODO: Listen for transaction updates to not miss purchase
                    let result = try await product.purchase()
                    return .purchased(product: product, result: result)
                } catch: { error in
                    return ._failedToPurchase(product)
                }

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

            case let ._failedToPurchase(product):
                print("Failed to purchase product \(product.id)")
                return .none

            case ._purchaseProductCancelled:
                return .none

            case ._purchaseProductPending:
                return .none

            case let ._purchaseProductSucceed(product, result):
                switch result {
                case .unverified:
                    print("Failed to verify tip signature....")
                case .verified:
                    print("Successfully purchased product: \(product.id)")
                }
                return .none

            case .freeLove:
                return .none
            }
        }
        .forEach(\.tipsAmounts, action: /Action.tipsAmount) {
            TipsAmount()
        }

        Scope(state: \.freeLove, action: /Action.freeLove) {
            FreeLove()
        }
    }

    private func loadTipsProducts(state: inout State) -> Effect<Action> {
        state.isLoadingProducts = true
        state.failedToFetchProducts = false
        return .task {
            let products = try await Product.products(for: TipsProductIdentifier.allCases.map(\.rawValue))
            return ._receivedProducts(products)
        } catch: { _ in
            ._failedToGetProducts
        }
    }
}

public struct FreeLove: Reducer {
    public struct State: Equatable {
        var highScore: Int = {
            @Dependency(\.favorites.freeLoveHighScore) var freeLoveHighScore
            return freeLoveHighScore
        }()
        var counter: Int = 0
    }

    public enum Action: Equatable {
        case loveButtonTapped
        case _resetCounter
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.favorites) var favorites

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loveButtonTapped:
            state.counter += 1
            return .task {
                try await clock.sleep(for: .seconds(1))
                return ._resetCounter
            }
            .animation(.easeIn)
            .cancellable(id: CancelID.reset, cancelInFlight: true)

        case ._resetCounter:
            let highScore = max(state.highScore, state.counter)
            state.highScore = highScore
            state.counter = 0
            return .fireAndForget {
                if favorites.freeLoveHighScore < highScore {
                    favorites.freeLoveHighScore = highScore
                }
            }
        }
    }

    private enum CancelID {
        case reset
    }
}

public struct TipsAmount: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: String { product.id }
        var product: Product
        var title: TextState { TextState(product.displayName) }
        var amount: TextState { TextState(product.displayPrice) }
    }

    public enum Action: Equatable {
        case buyButtonTapped
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

private extension TipsSection.Action {
    static func purchased(product: Product, result: Product.PurchaseResult) -> Self {
        switch result {
        case .userCancelled:
            return ._purchaseProductCancelled
        case .pending:
            return ._purchaseProductPending
        case let .success(result):
            return ._purchaseProductSucceed(product, result)
        @unknown default:
            return ._failedToPurchase(product)
        }
    }
}
