import ScheduleCore
import ComposableArchitecture

@Reducer
struct LoadedScheduleFeature {
    @ObservableState
    struct State {
        let response: ScheduleRequestResponse
    }
}
