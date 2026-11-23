import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirApi
import BsuirCore

@Reducer
struct ExamsScheduleFeature {
    @ObservableState
    struct State {
        @Shared var sharedNow: Date

        var days: IdentifiedArrayOf<DaySectionFeature.State> = []

        init(
            exams: [Pair],
            startDate: Date?,
            endDate: Date?,
            sharedNow: Shared<Date>
        ) {
            self._sharedNow = sharedNow

            @Dependency(\.calendar) var calendar

            self.load(
                exams: exams,
                calendar: calendar,
                now: sharedNow.wrappedValue
            )
        }
    }

    enum Action {
        enum Delegate {
            case switchToSchedule
        }

        case switchToScheduleTapped
        case days(IdentifiedActionOf<DaySectionFeature>)

        case delegate(Delegate)
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .switchToScheduleTapped:
                return .send(.delegate(.switchToSchedule))
            case .days, .delegate:
                return .none
            }
        }
        .forEach(\.days, action: \.days) {
            DaySectionFeature()
        }
    }
}

// MARK: - Load

private extension ExamsScheduleFeature.State {
    mutating func load(exams: [Pair], calendar: Calendar, now: Date) {
        let days = Dictionary(grouping: exams, by: \.dateLesson)
            .sorted(by: optionalSort(\.key))
            .map {
                DaySectionFeature.State(
                    date: $0,
                    now: now,
                    pairs: $1,
                    calendar: calendar,
                    sharedNow: $sharedNow
                )
            }

        self.days = IdentifiedArray(uniqueElements: days)
    }
}

private extension DaySectionFeature.State {
    init(date: Date?, now: Date, pairs: [Pair], calendar: Calendar, sharedNow: Shared<Date>) {
        assert(date != nil, "Not really expecting days without date")

        self.init(
            day: .exact(date),
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
            sharedNow: sharedNow
        )
    }
}
