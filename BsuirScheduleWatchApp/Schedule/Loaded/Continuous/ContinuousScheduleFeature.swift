import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirApi

@Reducer
struct ContinuousScheduleFeature {
    @ObservableState
    struct State {
        @Shared var sharedNow: Date

        var days: IdentifiedArrayOf<DaySectionFeature.State> = []

        var offset: Date?
        var weekSchedule: WeekSchedule?
        var loadMore: Bool = true

        init(
            schedule: DaySchedule,
            startDate: Date?,
            endDate: Date?,
            sharedNow: Shared<Date>
        ) {
            @Dependency(\.calendar) var calendar
            @Dependency(\.universityCalendar) var universityCalendar

            _sharedNow = sharedNow

            self.offset = calendar.date(byAdding: .day, value: -1, to: sharedNow.wrappedValue)

            if let startDate, let endDate {
                self.weekSchedule = WeekSchedule(
                    schedule: schedule,
                    startDate: startDate,
                    endDate: endDate
                )
            }

            load(count: 5, calendar: calendar, universityCalendar: universityCalendar)
        }
    }

    enum Action {
        case task
        case loadMore
        case days(IdentifiedActionOf<DaySectionFeature>)
    }

    @Dependency(\.calendar) var calendar
    @Dependency(\.universityCalendar) var universityCalendar

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.clipSchedule(calendar: calendar, universityCalendar: universityCalendar)
                return .none
            case .loadMore:
                state.load(count: 5, calendar: calendar, universityCalendar: universityCalendar)
                return .none
            case .days:
                return .none
            }
        }
        .forEach(\.days, action: \.days) {
            DaySectionFeature()
        }
    }
}

// MARK: - Load

private extension ContinuousScheduleFeature.State {
    static let loadBatchSize = 5

    mutating func load(count: Int, calendar: Calendar, universityCalendar: Calendar) {
        guard
            let weekSchedule = weekSchedule,
            let offset = offset,
            let start = calendar.date(byAdding: .day, value: 1, to: offset)
        else { loadMore = false; return }

        let newDays = Array(
            weekSchedule.schedule(
                starting: start,
                now: sharedNow,
                calendar: calendar,
                universityCalendar: universityCalendar
            ).prefix(count)
        )

        loadMore = newDays.count >= count

        self.offset = newDays.last?.date
        let newDaysFeatures = newDays.map { element in
            DaySectionFeature.State(
                element: element,
                sharedNow: $sharedNow
            )
        }

        days.append(contentsOf: newDaysFeatures)
    }

    mutating func clipSchedule(
        calendar: Calendar,
        universityCalendar: Calendar
    ) {
        // Find index of a day who's date is today or in the future
        guard let firstScheduleDayIndex = days.firstIndex(where: { state in
            guard case .continuous(let date, _) = state.day else { return false }
            return calendar.isDate(date, inSameDayAs: sharedNow) || date > sharedNow
        }) else { return }

        // Remove all days that have passed
        days.removeFirst(firstScheduleDayIndex)

        // Load more schedule if clipping almost all
        if days.count <= 3 {
            load(count: 5, calendar: calendar, universityCalendar: universityCalendar)
        }
    }
}

// MARK: - DaySectionFeature

private extension DaySectionFeature.State {
    init(
        element: WeekSchedule.ScheduleElement,
        sharedNow: Shared<Date>
    ) {
        self.init(
            day: .continuous(element.date, weekNumber: element.weekNumber),
            pairs: element.pairs.map { pair in
                PairViewModel(
                    start: pair.start,
                    end: pair.end,
                    pair: pair.base,
                    progress: .updating(start: pair.start, end: pair.end)
                )
            },
            sharedNow: sharedNow
        )
    }
}
