import Foundation
import ComposableArchitecture

@Reducer
public struct SubgroupPickerFeature {
    public struct State: Equatable {
        var selected: Int?
        var maxSubgroup: Int

        init(maxSubgroup: Int, selected: Int?) {
            self.maxSubgroup = maxSubgroup
            self.selected = selected
        }
    }

    public enum Action: Equatable {
        case setSelected(Int?)
    }

    public var body: some ReducerOf<Self> {
        Reduce{ state, action in
            switch action {
            case .setSelected(let value):
                state.selected = value
                return .none
            }
        }
    }
}
