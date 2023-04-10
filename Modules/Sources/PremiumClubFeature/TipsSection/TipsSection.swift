import Foundation
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

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
        var showCounter: Bool { counter > 0 }
        var counter: Int = 0
    }

    public enum Action: Equatable {
        case loveButtonTapped
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loveButtonTapped:
            state.counter += 1
            return .none
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
