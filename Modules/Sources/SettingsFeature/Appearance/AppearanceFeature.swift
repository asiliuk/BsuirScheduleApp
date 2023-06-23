import Foundation
import ComposableArchitecture

public struct AppearanceFeature: ReducerProtocol {
    public struct State: Equatable {
        var pairFormsColorPicker = PairFormsColorPicker.State()
    }

    public enum Action: Equatable {
        case pairFormsColorPicker(PairFormsColorPicker.Action)
    }

    public var body: some ReducerProtocolOf<Self> {
        Scope(state: \.pairFormsColorPicker, action: /Action.pairFormsColorPicker) {
            PairFormsColorPicker()
        }
    }
}
