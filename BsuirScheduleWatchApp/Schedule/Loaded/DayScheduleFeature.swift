import Foundation
import ComposableArchitecture
import BsuirApi
import ScheduleCore

@Reducer
struct DayScheduleFeature {
    @ObservableState
    struct State {
        var days: IdentifiedArrayOf<DaySectionFeature.State>

        init(daySchedule: DaySchedule) {
            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now
            days = IdentifiedArray(
                uniqueElements: Self.daySections(from: daySchedule, in: calendar, now: now)
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
        now: Date
    ) -> [DaySectionFeature.State] {
        DaySchedule.WeekDay.allCases.compactMap { weekDay -> DaySectionFeature.State? in
            guard
                let pairs = daySchedule[weekDay]?.filter({ $0.dateLesson == nil }),
                !pairs.isEmpty
            else { return nil }

            return DaySectionFeature.State(
                id: UUID(),
                title: weekDay.localizedName(in: calendar).localizedCapitalized,
                pairs: pairs.map { pair in
                    PairViewModel(
                        start: calendar.date(bySetting: pair.startLessonTime, of: now),
                        end: calendar.date(bySetting: pair.endLessonTime, of: now),
                        pair: pair,
                        progress: .notStarted
                    )
                }
            )
        }
    }
}
