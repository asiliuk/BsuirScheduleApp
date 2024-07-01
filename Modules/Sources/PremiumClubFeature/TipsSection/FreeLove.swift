import Foundation
import ComposableArchitecture

@Reducer
public struct FreeLove {
    @ObservableState
    public struct State: Equatable {
        @Shared(.freeLoveHighScore) var highScore
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
                return .none
            }
        }
    }

    private enum CancelID {
        case reset
    }
}
