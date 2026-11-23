import Foundation
import ScheduleCore
import ComposableArchitecture

@Reducer
struct LoadedScheduleFeature {
    @ObservableState
    struct State {
        let response: ScheduleRequestResponse
        var viewOptions: ScheduleViewOptionsFeature.State

        var continuous: ContinuousScheduleFeature.State
        var day: DayScheduleFeature.State

        @Shared var sharedNow: Date

        init(response: ScheduleRequestResponse) {
            self.response = response
            self.viewOptions = ScheduleViewOptionsFeature.State()
            
            @Dependency(\.date.now) var now
            self._sharedNow = Shared(value: now)

            self.continuous = ContinuousScheduleFeature.State(
                schedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate,
                sharedNow: _sharedNow
            )

            self.day = DayScheduleFeature.State(
                daySchedule: response.schedule,
                sharedNow: _sharedNow
            )
        }
    }

    enum Action {
        case continuous(ContinuousScheduleFeature.Action)
        case day(DayScheduleFeature.Action)
        case viewOptions(ScheduleViewOptionsFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(\.viewOptions, action: \.viewOptions) {
            ScheduleViewOptionsFeature()
        }

        Scope(\.continuous, action: \.continuous) {
            ContinuousScheduleFeature()
        }

        Scope(\.day, action: \.day) {
            DayScheduleFeature()
        }
    }
}
