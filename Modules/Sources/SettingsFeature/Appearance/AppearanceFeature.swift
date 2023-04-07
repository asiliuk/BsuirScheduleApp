import Foundation
import ComposableArchitecture

public struct AppearanceFeature: Reducer {
    public struct State: Equatable {
        var pairFormsColorPicker = PairFormsColorPicker.State()
    }

    public enum Action: Equatable {
        case pairFormsColorPicker(PairFormsColorPicker.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.pairFormsColorPicker, action: /Action.pairFormsColorPicker) {
            PairFormsColorPicker()
        }
    }
}
