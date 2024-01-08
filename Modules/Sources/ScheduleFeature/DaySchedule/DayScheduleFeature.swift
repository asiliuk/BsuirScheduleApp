import Foundation
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

public struct DayScheduleFeature: Reducer {
    public struct State: Equatable {
        var scheduleList = ScheduleListFeature.State(days: [], loading: .never)

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
        Scope(state: \.scheduleList, action: /Action.scheduleList) {
            ScheduleListFeature()
        }
    }
}

extension DayScheduleFeature.State {
    public mutating func reset() {
        scheduleList.isOnTop = true
    }
}

private extension DayScheduleFeature.State {
    mutating func loadDays(
        schedule: DaySchedule,
        calendar: Calendar,
        now: Date
    ) {
        let days = DaySchedule.WeekDay.allCases
            .compactMap { (weekday: DaySchedule.WeekDay) -> DaySectionFeature.State? in
                guard
                    let pairs = schedule[weekday]?.filter({ $0.dateLesson == nil }),
                    !pairs.isEmpty
                else { return nil }

                return DaySectionFeature.State(
                    dayDate: .weekday(weekday),
                    showWeeks: true,
                    pairs: pairViewModels(pairs, calendar: calendar, now: now),
                    pairRowDetails: nil,
                    pairRowDay: .weekday(weekday)
                )
            }
        scheduleList.days = IdentifiedArray(uniqueElements: days)
    }

    func pairViewModels(
        _ pairs: [Pair],
        calendar: Calendar,
        now: Date
    ) -> [PairViewModel] {
        pairs.map {
            PairViewModel(
                start: calendar.date(bySetting: $0.startLessonTime, of: now),
                end: calendar.date(bySetting: $0.endLessonTime, of: now),
                pair: $0,
                progress: .notStarted
            )
        }
    }
}

// MARK: - Filter

extension DayScheduleFeature.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        scheduleList.filter(keepingSubgroup: subgroup)
    }
}
