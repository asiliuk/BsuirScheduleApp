import Foundation
import ComposableArchitecture

public struct AppearanceFeature: Reducer {
    public struct State: Equatable {
        var pairFormsColorPicker = PairFormsColorPicker.State()
        var pairFormIcons = PairFormIcons.State()
    }

    public enum Action: Equatable {
        case pairFormsColorPicker(PairFormsColorPicker.Action)
        case pairFormIcons(PairFormIcons.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.pairFormsColorPicker, action: /Action.pairFormsColorPicker) {
            PairFormsColorPicker()
        }

        Scope(state: \.pairFormIcons, action: /Action.pairFormIcons) {
            PairFormIcons()
        }
    }
}
