import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

public struct AppearanceFeature: ReducerProtocol {
    public struct State: Equatable {
        var pairFormsColorPicker = PairFormsColorPicker.State()
    }

    public enum Action: Equatable {
        case pairFormsColorPicker(PairFormsColorPicker.Action)
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.pairFormsColorPicker, action: /Action.pairFormsColorPicker) {
            PairFormsColorPicker()
        }
    }
}
