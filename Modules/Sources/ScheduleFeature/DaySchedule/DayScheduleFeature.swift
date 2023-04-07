import Foundation
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

public struct DayScheduleFeature: Reducer {
    public struct State: Equatable {
        public var isOnTop: Bool = true
        var days: [ScheduleDayViewModel] = []

        init(schedule: DaySchedule) {
            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now
            @Dependency(\.uuid) var uuid

            self.loadDays(
                schedule: schedule,
                calendar: calendar,
                now: now,
                uuid: uuid
            )
        }
    }

    public enum Action: Equatable {
        case setIsOnTop(Bool)
    }

    public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .setIsOnTop(let value):
            state.isOnTop = value
            return .none
        }
    }
}

private extension DayScheduleFeature.State {
    mutating func loadDays(
        schedule: DaySchedule,
        calendar: Calendar,
        now: Date,
        uuid: UUIDGenerator
    ) {
        days = DaySchedule.WeekDay.allCases
            .compactMap { (weekday: DaySchedule.WeekDay) -> ScheduleDayViewModel? in
                guard
                    let pairs = schedule[weekday],
                    !pairs.isEmpty
                else { return nil }

                return ScheduleDayViewModel(
                    id: uuid(),
                    title: weekday.localizedName(in: calendar).capitalized,
                    pairs: pairViewModels(pairs, calendar: calendar, now: now)
                )
            }
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
                pair: $0
            )
        }
    }
}
