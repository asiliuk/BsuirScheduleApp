import Foundation
import ScheduleCore
import ComposableArchitecture
import BsuirApi

@Reducer
public struct DaySectionFeature {
    @ObservableState
    public struct State: Identifiable {
        public enum DayDate {
            case continuousDate(Date, weekNumber: Int)
            case weekday(DaySchedule.WeekDay)
            case examDate(Date?)
        }

        enum Relativity {
            case past
            case today
            case future
        }

        public var id: UUID
        var dayDate: DayDate
        var pairRows: IdentifiedArrayOf<PairRowFeature.State>

        init(
            dayDate: DayDate,
            showWeeks: Bool = false,
            pairs: [PairViewModel],
            pairRowDetails: PairRowDetails?,
            pairRowDay: PairRowDay
        ) {
            @Dependency(\.uuid) var uuid
            self.id = uuid()
            self.dayDate = dayDate
            self.pairRows = IdentifiedArray(
                uniqueElements: pairs.map { pair in
                    PairRowFeature.State(
                        pair: pair,
                        showWeeks: showWeeks,
                        details: pairRowDetails,
                        day: pairRowDay
                    )
                }
            )
        }
    }

    @CasePathable
    public enum Action {
        case pairRows(IdentifiedActionOf<PairRowFeature>)
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
        .forEach(\.pairRows, action: \.pairRows) {
            PairRowFeature()
        }
    }

}

// MARK: - Helpers

extension DaySectionFeature.State.DayDate {
    var title: String {
        switch self {
        case .continuousDate(let date, let weekNumber):
            return String(localized: "screen.schedule.day.title.\(date.formatted(.scheduleDay)).\(weekNumber)")
        case .weekday(let weekday):
            @Dependency(\.calendar) var calendar
            return weekday.localizedName(in: calendar).capitalized
        case .examDate(let date):
            return date?.formatted(.examDay) ?? "-/-"
        }
    }

    func subtitle(for now: Date) -> String? {
        switch self {
        case .continuousDate(let date, _):
            Self.relativeFormatter.relativeName(for: date, now: now)
        case .weekday:
            nil
        case .examDate(let date):
            date.flatMap { Self.relativeFormatter.relativeName(for: $0, now: now) }
        }
    }

    func relativity(for now: Date) -> DaySectionFeature.State.Relativity {
        switch self {
        case .continuousDate(let date, _):
            relativity(for: date, now: now)
        case .weekday:
            .future
        case .examDate(let date):
            date.map { relativity(for: $0, now: now) } ?? .future
        }
    }

    private func relativity(for date: Date, now: Date) -> DaySectionFeature.State.Relativity {
        @Dependency(\.calendar) var calendar
        if calendar.isDate(date, inSameDayAs: now) {
            return .today
        } else if date < now {
            return .past
        } else {
            return .future
        }
    }

    private static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()
}
