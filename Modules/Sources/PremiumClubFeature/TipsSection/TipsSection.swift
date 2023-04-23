import Foundation
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI
import Favorites

public struct TipsSection: Reducer {
    public struct State: Equatable {
        var tipsAmounts: IdentifiedArrayOf<TipsAmount.State> = [
            .init(title: TextState("☕️ Small tip"), amount: 0.99, currencyCode: "EUR"),
            .init(title: TextState("🥐 Medium tip"), amount: 2.99, currencyCode: "EUR"),
            .init(title: TextState("🥙 Big tip"), amount: 6.99, currencyCode: "EUR"),
        ]
        var freeLove: FreeLove.State = .init()
    }

    public enum Action: Equatable {
        case tipsAmount(id: TipsAmount.State.ID, action: TipsAmount.Action)
        case freeLove(FreeLove.Action)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tipsAmount(id, action: .buyButtonTapped):
                guard let tipsAmount = state.tipsAmounts[id: id] else {
                    return .none
                }
                print("Purchasing tips with amount \(tipsAmount.amount)")
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
            enum CancelID: Hashable {}
            state.counter += 1
            return .task {
                try await clock.sleep(for: .seconds(1))
                return ._resetCounter
            }
            .animation(.easeIn)
            .cancellable(id: CancelID.self, cancelInFlight: true)

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
