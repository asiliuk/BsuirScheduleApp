import ComposableArchitecture
import Foundation

@Reducer
struct ContentFeature {
    @ObservableState
    struct State: Equatable {
        var counter: Int = 0
    }

    enum Action {
        case incrementButtonTapped
        case decrementButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.counter += 1
                return .none
            case .decrementButtonTapped:
                state.counter -= 1
                return .none
            }
        }
    }
}
