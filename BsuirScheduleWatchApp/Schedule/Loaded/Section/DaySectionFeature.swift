import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirApi
import BsuirCore

@Reducer
struct DaySectionFeature {
    @ObservableState
    struct State {
        nonisolated enum Day: Hashable {
            case continuous(Date, weekNumber: Int)
            case weekDay(DaySchedule.WeekDay)
            case exact(Date?)
        }

        let day: Day
        var pairs: [PairViewModel]
        @Shared var sharedNow: Date
    }
}

// MARK: - Identifiable

extension DaySectionFeature.State: Identifiable {
    var id: Day { day }
}

// MARK: - Relativity

extension DaySectionFeature.State {
    struct Relativity {
        let title: String?
        let order: ComparisonResult
    }

    var relativity: Relativity {
        switch day {
        case let .continuous(date, _), let .exact(date?):
            Relativity(date: date, now: sharedNow)
        case .weekDay:
            .future
        case .exact(nil):
            .past
        }
    }
}

private extension DaySectionFeature.State.Relativity {
    init(date: Date, now: Date) {
        @Dependency(\.calendar) var calendar
        title = Self.relativeFormatter.relativeName(for: date, now: now)
        order = if calendar.isDate(date, inSameDayAs: now) {
            .orderedSame
        } else if date < now {
            .orderedAscending
        } else {
            .orderedDescending
        }
    }

    static let past = Self(title: nil, order: .orderedAscending)
    static let future = Self(title: nil, order: .orderedDescending)

    private static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()
}
