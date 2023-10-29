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
        var dayDate: DayDate
        var title: String = ""
        var subtitle: String? = nil
        var isToday: Bool = false
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
        case onAppear
        case pairRow(id: PairRowFeature.State.ID, action: PairRowFeature.Action)
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
                    state.isToday = calendar.isDate(date, inSameDayAs: now)
                case .weekday(let weekday):
                    state.title = weekday.localizedName(in: calendar).capitalized
                    state.subtitle = nil
                    state.isToday = false
                case .examDate(let date):
                    state.title = date?.formatted(.examDay) ?? "-/-"
                    state.subtitle = date.flatMap { Self.relativeFormatter.relativeName(for: $0, now: now) }
                    state.isToday = date.map { calendar.isDate($0, inSameDayAs: now) } ?? false
                }
                return .none
            case .pairRow:
                return .none
            }
        }
        .forEach(\.pairRows, action: /Action.pairRow) {
            PairRowFeature()
        }
    }

    private static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()
}

// MARK: - Filter

extension DaySectionFeature.State {
    mutating func filter(keepingSubgroup: Int?) {
        func isFiltered(subgroup: Int) -> Bool {
            guard let keepingSubgroup, subgroup > 0 else { return false }
            return subgroup != keepingSubgroup
        }

        for index in pairRows.indices {
            pairRows[index].isFiltered = isFiltered(subgroup: pairRows[index].pair.subgroup)
        }
    }
}
