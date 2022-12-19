import Foundation
import BsuirCore
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import ComposableArchitectureUtils
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

public struct ContiniousScheduleFeature: ReducerProtocol {
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
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case loadMoreIndicatorAppear
            case setIsOnTop(Bool)
        }
        
        public enum ReducerAction {
            case loadMoreDays
        }
        
        public typealias DelegateAction = Never
        
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.reviewRequestService) var reviewRequestService
    
    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .view(.setIsOnTop(let value)):
            state.isOnTop = value
            return .none
        case .view(.loadMoreIndicatorAppear):
            return .task {
                try await Task.sleep(nanoseconds: 300_000_000)
                return .reducer(.loadMoreDays)
            }

        case .reducer(.loadMoreDays):
            state.load(count: 10)
            return .fireAndForget {
                reviewRequestService.madeMeaningfulEvent(.moreScheduleRequested)
            }

        case .delegate:
            return .none
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
