import Foundation
import ComposableArchitecture

@Reducer
public struct SubgroupPickerFeature {
    @ObservableState
    public struct State: Equatable {
        var selected: Int?
        var maxSubgroup: Int

        init(maxSubgroup: Int, selected: Int?) {
            self.maxSubgroup = maxSubgroup
            self.selected = selected
        }
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
    }
}
