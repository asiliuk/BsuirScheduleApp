import ScheduleCore
import ComposableArchitecture

@Reducer
struct LoadedScheduleFeature {
    @ObservableState
    struct State {
        let response: ScheduleRequestResponse
        var day: DayScheduleFeature.State

        init(response: ScheduleRequestResponse) {
            self.response = response
            self.day = DayScheduleFeature.State(daySchedule: response.schedule)
        }
    }

    enum Action {
        case day(DayScheduleFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(\.day, action: \.day) {
            DayScheduleFeature()
        }
    }
}
