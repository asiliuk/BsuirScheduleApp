import Foundation
import ScheduleCore
import ComposableArchitecture
import BsuirApi

public struct DaySectionFeature: Reducer {
    public struct State: Equatable, Identifiable {
        public enum DayDate: Equatable {
            case continuousDate(Date, weekNumber: Int)
            case weekday(DaySchedule.WeekDay)
            case examDate(Date?)
        }

        public var id: UUID
        private var dayDate: DayDate
        private static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()

        var title: String {
            switch dayDate {
            case .continuousDate(let date, let weekNumber):
                return String(localized: "screen.schedule.day.title.\(date.formatted(.scheduleDay)).\(weekNumber)")
            case .weekday(let weekday):
                @Dependency(\.calendar) var calendar
                return weekday.localizedName(in: calendar).capitalized
            case .examDate(let date):
                return date?.formatted(.examDay) ?? "-/-"
            }
        }

        var subtitle: String? {
            switch dayDate {
            case .continuousDate(let date, _), .examDate(let date?):
                @Dependency(\.date.now) var now
                return Self.relativeFormatter.relativeName(for: date, now: now)
            case .weekday, .examDate(nil):
                return nil
            }
        }

        var isToday: Bool {
            switch dayDate {
            case .continuousDate(let date, _), .examDate(let date?):
                @Dependency(\.calendar) var calendar
                return calendar.isDateInToday(date)
            case .weekday, .examDate(nil):
                return false
            }
        }

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

    public enum Action: Equatable {
        case pairRow(id: PairRowFeature.State.ID, action: PairRowFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .forEach(\.pairRows, action: /Action.pairRow) {
                PairRowFeature()
            }
    }
}
