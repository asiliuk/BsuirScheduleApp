import Foundation
import ComposableArchitecture
import BsuirApi
import ScheduleCore

@Reducer
struct DayScheduleFeature {
    @ObservableState
    struct State {
        @Shared var sharedNow: Date

        var days: IdentifiedArrayOf<DaySectionFeature.State>

        var startDate: Date?
        var endDate: Date?

        init(
            daySchedule: DaySchedule,
            startDate: Date?,
            endDate: Date?,
            sharedNow: Shared<Date>
        ) {
            self._sharedNow = sharedNow
            self.startDate = startDate
            self.endDate = endDate

            @Dependency(\.calendar) var calendar

            days = IdentifiedArray(
                uniqueElements: Self.daySections(
                    from: daySchedule,
                    in: calendar,
                    sharedNow: sharedNow
                )
            )
        }
    }

    enum Action {
        case days(IdentifiedActionOf<DaySectionFeature>)
    }

    var body: some Reducer<State, Action> {
        Reduce { _, _ in
            return .none
        }
        .forEach(\.days, action: \.days) {
            DaySectionFeature()
        }
    }
}

// MARK: - Days

private extension DayScheduleFeature.State {
    static func daySections(
        from daySchedule: DaySchedule,
        in calendar: Calendar,
        sharedNow: Shared<Date>
    ) -> [DaySectionFeature.State] {
        DaySchedule.WeekDay.allCases.compactMap { weekDay -> DaySectionFeature.State? in
            guard
                let pairs = daySchedule[weekDay]?.filter({ $0.dateLesson == nil }),
                !pairs.isEmpty
            else { return nil }

            return DaySectionFeature.State(
                day: .weekDay(weekDay),
                pairs: pairs.map { pair in
                    PairViewModel(
                        start: calendar.date(bySetting: pair.startLessonTime, of: sharedNow.wrappedValue),
                        end: calendar.date(bySetting: pair.endLessonTime, of: sharedNow.wrappedValue),
                        pair: pair,
                        progress: .notStarted
                    )
                },
                sharedNow: sharedNow
            )
        }
    }
}
