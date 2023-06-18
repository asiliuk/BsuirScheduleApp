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
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return loadTipsProducts(state: &state)
            case .reloadTips:
                return loadTipsProducts(state: &state)
            case let .tipsAmount(id, action: .buyButtonTapped):
                guard let tipsAmount = state.tipsAmounts[id: id] else {
                    return .none
                }
                print("Purchasing tips with amount \(tipsAmount.amount)")
                return .none

            case let ._receivedProducts(products):
                state.isLoadingProducts = false
                state.failedToFetchProducts = false
                state.tipsAmounts = []
                for product in products where product.type == .consumable {
                    let tipsAmount = TipsAmount.State(
                        title: TextState(product.displayName),
                        amount: TextState(product.displayPrice)
                    )
                    state.tipsAmounts.append(tipsAmount)
                }
                return .none

            case ._failedToGetProducts:
                state.isLoadingProducts = false
                state.failedToFetchProducts = true
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
        public var id: TextState { title }
        var title: TextState
        var amount: TextState
    }

    public enum Action: Equatable {
        case buyButtonTapped
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

private extension TipsAmount.State {
    init(title: TextState, amount: Decimal, currencyCode: String) {
        self.title = title
        self.amount = TextState(amount.formatted(.currency(code: currencyCode)))
    }
}
