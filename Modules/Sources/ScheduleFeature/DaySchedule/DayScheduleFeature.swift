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

        mutating func filter(keepingSubgroup subgroup: Int?) {
            scheduleList.filter(keepingSubgroup: subgroup)
        }

        init(schedule: DaySchedule, startDate: Date?, endDate: Date?) {
            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now

            self.scheduleList = ScheduleListFeature.State(
                scheduleType: .compact,
                days: [],
                loading: .never,
                title: "🗓️ \(LocalizedStringResource("screen.schedule.scheduleType.byDay"))",
                subtitle: {
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
