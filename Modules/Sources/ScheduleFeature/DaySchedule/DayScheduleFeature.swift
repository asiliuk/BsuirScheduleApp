import Foundation
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

@Reducer
public struct DayScheduleFeature {
    public struct State: Equatable {
        var scheduleList = ScheduleListFeature.State(days: [], loading: .never)

        mutating func filter(keepingSubgroup subgroup: Int?) {
            scheduleList.filter(keepingSubgroup: subgroup)
        }

        public mutating func reset() {
            scheduleList.isOnTop = true
        }

        init(schedule: DaySchedule) {
            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now

            self.loadDays(
                schedule: schedule,
                calendar: calendar,
                now: now
            )
        }
    }

    public enum Action: Equatable {
        case scheduleList(ScheduleListFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.scheduleList, action: \.scheduleList) {
            ScheduleListFeature()
        }
    }
}
