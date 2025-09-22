import Foundation
import IdentifiedCollections
import BsuirApi
import ScheduleCore

extension DayScheduleFeature.State {
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
                    pairRowDay: .weekday(weekday),
                    sharedNow: $sharedNow
                )
            }
        scheduleList.days = IdentifiedArray(uniqueElements: days)
    }

    private func pairViewModels(
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
