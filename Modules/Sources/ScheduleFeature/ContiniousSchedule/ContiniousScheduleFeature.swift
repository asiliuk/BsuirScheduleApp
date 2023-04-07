import Foundation
import BsuirCore
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

private extension ScheduleDayViewModel {
    init(
        element: WeekSchedule.ScheduleElement,
        uuid: UUIDGenerator,
        calendar: Calendar,
        now: Date
    ) {
        self.init(
            id: uuid(),
            title: String(localized: "screen.schedule.day.title.\(element.date.formatted(.scheduleDay)).\(element.weekNumber)"),
            subtitle: Self.relativeFormatter.relativeName(for: element.date, now: now),
            pairs: element.pairs.map(PairViewModel.init(pair:)),
            isToday: calendar.isDateInToday(element.date)
        )
    }

    static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()
}

public struct ContiniousScheduleFeature: Reducer {
    public struct State {
        public var isOnTop: Bool = true
        public var isEmpty: Bool { days.isEmpty }

        private(set) var days: [ScheduleDayViewModel] = []
        private(set) var doneLoading: Bool = false

        private var offset: Date?
        private var weekSchedule: WeekSchedule?

        @Dependency(\.calendar) private var calendar
        @Dependency(\.date.now) private var now
        @Dependency(\.uuid) private var uuid
        
        init(schedule: DaySchedule, startDate: Date?, endDate: Date?) {
            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now
            @Dependency(\.uuid) var uuid

            self.offset = calendar.date(byAdding: .day, value: -1, to: now)
            if let startDate, let endDate {
                self.weekSchedule = WeekSchedule(
                    schedule: schedule,
                    startDate: startDate,
                    endDate: endDate
                )
            }

            load(count: 12)
        }
    }
    
    public enum Action: Equatable {
        case loadMoreIndicatorAppear
        case setIsOnTop(Bool)
        
        case _loadMoreDays
    }
    
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.continuousClock) var clock
    
    public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .setIsOnTop(let value):
            state.isOnTop = value
            return .none
        case .loadMoreIndicatorAppear:
            enum TaskID {}
            return .task {
                try await withTaskCancellation(id: TaskID.self, cancelInFlight: true) {
                    try await clock.sleep(for: .milliseconds(300))
                    return ._loadMoreDays
                }
            }

        case ._loadMoreDays:
            state.load(count: 10)
            return .fireAndForget {
                await reviewRequestService.madeMeaningfulEvent(.moreScheduleRequested)
            }
        }
    }
}

private extension MeaningfulEvent {
    static let moreScheduleRequested = Self(score: 1)
}

// MARK: - Equatable

extension ContiniousScheduleFeature.State: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.days == rhs.days
            && lhs.doneLoading == rhs.doneLoading
            && lhs.offset == rhs.offset
    }
}

// MARK: - Load More

extension ContiniousScheduleFeature.State {
    mutating func load(count: Int) {
        guard
            let weekSchedule = weekSchedule,
            let offset = offset,
            let start = calendar.date(byAdding: .day, value: 1, to: offset)
        else { return }

        let days = Array(weekSchedule.schedule(starting: start, now: now, calendar: calendar).prefix(count))
        doneLoading = days.count < count

        self.offset = days.last?.date
        self.days.append(
            contentsOf: days.map { element in
                ScheduleDayViewModel(
                    element: element,
                    uuid: uuid,
                    calendar: calendar,
                    now: now
                )
            }
        )
    }
}
