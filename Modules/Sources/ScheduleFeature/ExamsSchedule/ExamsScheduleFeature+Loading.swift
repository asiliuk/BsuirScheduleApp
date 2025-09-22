import Foundation
import BsuirApi
import IdentifiedCollections
import ScheduleCore
import Sharing

extension ExamsScheduleFeature.State {
    mutating func loadDays(
        exams: [Pair],
        calendar: Calendar,
        now: Date
    ) {
        let days = Dictionary(grouping: exams, by: \.dateLesson)
            .sorted(by: optionalSort(\.key))
            .map {
                DaySectionFeature.State(
                    date: $0,
                    now: now,
                    pairs: $1,
                    pairRowDetails: pairRowDetails ,
                    calendar: calendar,
                    sharedNow: $sharedNow
                )
            }
        scheduleList.days = IdentifiedArray(uniqueElements: days)
    }
}

private extension DaySectionFeature.State {
    init(date: Date?, now: Date, pairs: [Pair], pairRowDetails: PairRowDetails?, calendar: Calendar, sharedNow: Shared<Date>) {
        assert(date != nil, "Not really expecting days without date")

        self.init(
            dayDate: .examDate(date),
            pairs: pairs
                .map { pair in
                    let start = calendar.date(bySetting: pair.startLessonTime, of: date ?? now)
                    let end = calendar.date(bySetting: pair.endLessonTime, of: date ?? now)
                    return (start, end, pair)
                }
                .sorted(by: optionalSort(\.0))
                .map { (start, end, pair) in
                    PairViewModel(
                        start: start,
                        end: end,
                        pair: pair,
                        progress: {
                            guard let start, let end else { return .notStarted }
                            return .updating(start: start, end: end)
                        }()
                    )
                },
            pairRowDetails: pairRowDetails,
            pairRowDay: .date(date),
            sharedNow: sharedNow
        )
    }
}

private func optionalSort<T, V: Comparable>(_ keyPath: KeyPath<T, V?>) -> (T, T) -> Bool {
    return { lhs, rhs in
        switch (lhs[keyPath: keyPath], rhs[keyPath: keyPath]) {
        case (nil, nil): return false
        case (nil,.some): return true
        case (.some, nil): return false
        case let (lhs?, rhs?): return lhs < rhs
        }
    }
}
