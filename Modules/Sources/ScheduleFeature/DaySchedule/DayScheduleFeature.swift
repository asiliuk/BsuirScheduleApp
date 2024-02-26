import Foundation
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

@Reducer
public struct DayScheduleFeature {
    @ObservableState
    public struct State: Equatable {
        var scheduleList: ScheduleListFeature.State

        mutating func filter(keepingSubgroup subgroup: Int?) {
            scheduleList.filter(keepingSubgroup: subgroup)
        }

        public mutating func reset() {
            scheduleList.isOnTop = true
        }

        init(schedule: DaySchedule, startDate: Date?, endDate: Date?) {
            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now

            self.scheduleList = ScheduleListFeature.State(
                days: [],
                loading: .never,
                header: {
                    guard let startDate, let endDate else { return nil }
                    return "screen.schedule.pairs.interval.title\((startDate..<endDate).formatted(.scheduleDates))"
                }()
            )

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
