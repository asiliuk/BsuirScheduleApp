import Foundation
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

@Reducer
public struct DayScheduleFeature {
    @ObservableState
    public struct State {
        var scheduleList: ScheduleListFeature.State
        @Shared var sharedNow: Date

        init(schedule: DaySchedule, startDate: Date?, endDate: Date?, sharedNow: Shared<Date>) {
            @Dependency(\.calendar) var calendar

            self._sharedNow = sharedNow
            self.scheduleList = ScheduleListFeature.State(
                scheduleType: .compact,
                days: [],
                loading: .never,
                startDate: startDate,
                endDate: endDate
            )

            self.loadDays(
                schedule: schedule,
                calendar: calendar,
                now: sharedNow.wrappedValue
            )
        }
    }

    public enum Action {
        case scheduleList(ScheduleListFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.scheduleList, action: \.scheduleList) {
            ScheduleListFeature()
        }
    }
}
