import Foundation
import ComposableArchitecture

@Reducer
public struct SubgroupPickerFeature {
    @ObservableState
    public struct State {
        var selected: Int?
        var maxSubgroup: Int

        init(maxSubgroup: Int, selected: Int?) {
            self.maxSubgroup = maxSubgroup
            self.selected = selected
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
    }
}
