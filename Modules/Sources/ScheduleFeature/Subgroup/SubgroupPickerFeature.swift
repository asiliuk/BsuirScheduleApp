import Foundation
import ComposableArchitecture

public struct SubgroupPickerFeature: Reducer {
    public struct State: Equatable {
        var selected: Int?
        var maxSubgroup: Int

        init(maxSubgroup: Int) {
            self.maxSubgroup = maxSubgroup
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
