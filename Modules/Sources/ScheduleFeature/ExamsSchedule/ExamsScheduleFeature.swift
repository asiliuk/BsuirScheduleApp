import Foundation
import BsuirCore
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

public struct ExamsScheduleFeature: Reducer {
    public struct State: Equatable {
        var scheduleList = ScheduleListFeature.State(days: [], loading: .never)
        private var pairRowDetails: PairRowDetails?

        init(exams: [Pair], startDate: Date?, endDate: Date?, pairRowDetails: PairRowDetails?) {
            self.pairRowDetails = pairRowDetails

            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now

            self.loadDays(
                exams: exams,
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

// MARK: - Filter

extension ExamsScheduleFeature.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        scheduleList.filter(keepingSubgroup: subgroup)
    }
}

// MARK: - Reset

extension ExamsScheduleFeature.State {
    public mutating func reset() {
        scheduleList.isOnTop = true
    }
}

// MARK: - Helpers

private extension ExamsScheduleFeature.State {
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
                    calendar: calendar
                )
            }
        scheduleList.days = IdentifiedArray(uniqueElements: days)
    }
}

private extension DaySectionFeature.State {
    init(date: Date?, now: Date, pairs: [Pair], pairRowDetails: PairRowDetails?, calendar: Calendar) {
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
                .map { PairViewModel(start: $0, end: $1, pair: $2, progress: .notStarted) },
            pairRowDetails: pairRowDetails,
            pairRowDay: .date(date)
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
