import Foundation
import ComposableArchitecture

@Reducer
public struct AppearanceFeature {
    @ObservableState
    public struct State {
        var pairFormsColorPicker = PairFormsColorPicker.State()
        var pairFormIcons = PairFormIcons.State()
    }

    public enum Action {
        case pairFormsColorPicker(PairFormsColorPicker.Action)
        case pairFormIcons(PairFormIcons.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.pairFormsColorPicker, action: \.pairFormsColorPicker) {
            PairFormsColorPicker()
        }

        Scope(state: \.pairFormIcons, action: \.pairFormIcons) {
            PairFormIcons()
        }
    }
}
