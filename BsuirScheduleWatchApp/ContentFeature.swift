import ComposableArchitecture
import Foundation
import Favorites
import SwiftUI

@Reducer
struct ContentFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.freeLoveHighScore) var highScore
        var counter: Int = 0
    }

    enum Action {
        case incrementButtonTapped
        case decrementButtonTapped
        case _resetCounter
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.favorites) var favorites

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.counter += 1
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(._resetCounter, animation: .easeIn)
                }
                .cancellable(id: CancelID.reset, cancelInFlight: true)

            case .decrementButtonTapped:
                state.counter -= 1
                return .none
            case ._resetCounter:
                let score = state.counter
                state.counter = 0
                guard score > state.highScore else { return .none }
                state.$highScore.withLock { $0 = score }
                return .none
            }
        }
    }

    nonisolated private enum CancelID: Sendable {
        case reset
    }
}
