import ScheduleCore
import ComposableArchitecture

@Reducer
struct LoadedScheduleFeature {
    @ObservableState
    struct State {
        let response: ScheduleRequestResponse
        var viewOptions: ScheduleViewOptionsFeature.State
        var day: DayScheduleFeature.State

        init(response: ScheduleRequestResponse) {
            self.response = response
            self.viewOptions = ScheduleViewOptionsFeature.State()
            self.day = DayScheduleFeature.State(daySchedule: response.schedule)
        }
    }

    enum Action {
        case day(DayScheduleFeature.Action)
        case viewOptions(ScheduleViewOptionsFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(\.viewOptions, action: \.viewOptions) {
            ScheduleViewOptionsFeature()
        }

        Scope(\.day, action: \.day) {
            DayScheduleFeature()
        }
    }
}
