import Foundation
import ScheduleCore
import ComposableArchitecture
import BsuirApi

@Reducer
public struct DaySectionFeature {
    public struct State: Equatable, Identifiable {
        public enum DayDate: Equatable {
            case continuousDate(Date, weekNumber: Int)
            case weekday(DaySchedule.WeekDay)
            case examDate(Date?)
        }

        enum Relativity {
            case past
            case today
            case future

            fileprivate init(for date: Date, now: Date, calendar: Calendar) {
                if calendar.isDate(date, inSameDayAs: now) {
                    self = .today
                } else if date < now {
                    self = .past
                } else {
                    self = .future
                }
            }
        }

        public var id: UUID
        var dayDate: DayDate
        var title: String = ""
        var subtitle: String? = nil
        var relativity: Relativity = .future
        var pairRows: IdentifiedArrayOf<PairRowFeature.State>
        var keepingSubgroup: Int?

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
    public enum Action: Equatable {
        case onAppear
        case pairRows(IdentifiedActionOf<PairRowFeature>)
    }

    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                switch state.dayDate {
                case .continuousDate(let date, let weekNumber):
                    state.title = String(localized: "screen.schedule.day.title.\(date.formatted(.scheduleDay)).\(weekNumber)")
                    state.subtitle = Self.relativeFormatter.relativeName(for: date, now: now)
                    state.relativity = State.Relativity(for: date, now: now, calendar: calendar)
                case .weekday(let weekday):
                    state.title = weekday.localizedName(in: calendar).capitalized
                    state.subtitle = nil
                    state.relativity = .future
                case .examDate(let date):
                    state.title = date?.formatted(.examDay) ?? "-/-"
                    state.subtitle = date.flatMap { Self.relativeFormatter.relativeName(for: $0, now: now) }
                    state.relativity = date.map { State.Relativity(for: $0, now: now, calendar: calendar) } ?? .future
                }
                state.filter(keepingSubgroup: state.keepingSubgroup)
                return .none
            case .pairRows:
                return .none
            }
        }
        .forEach(\.pairRows, action: \.pairRows) {
            PairRowFeature()
        }
    }

    private static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()
}
