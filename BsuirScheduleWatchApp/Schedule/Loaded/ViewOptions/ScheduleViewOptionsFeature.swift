import ComposableArchitecture
import ScheduleCore

@Reducer
struct ScheduleViewOptionsFeature {
    @ObservableState
    struct State {
        var displayType: ScheduleDisplayType = .continuous
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
    }
}
