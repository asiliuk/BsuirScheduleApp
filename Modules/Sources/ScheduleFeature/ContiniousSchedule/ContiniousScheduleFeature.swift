import Foundation
import BsuirCore
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

@Reducer
public struct ContinuousScheduleFeature {
    @ObservableState
    public struct State {
        public var hasSchedule: Bool { scheduleList.hasSchedule }

        var scheduleList = ScheduleListFeature.State(days: [], loading: .loadMore)

        var offset: Date?
        var weekSchedule: WeekSchedule?
        var pairRowDetails: PairRowDetails?

        // Keep track of currently applied subgroup filter
        // to make sure we'll keep filtering newly added pairs to the list
        var keepingSubgroup: Int?

        mutating func filter(keepingSubgroup subgroup: Int?) {
            keepingSubgroup = subgroup
            scheduleList.filter(keepingSubgroup: subgroup)
        }

        init(
            schedule: DaySchedule,
            startDate: Date?,
            endDate: Date?,
            pairRowDetails: PairRowDetails?
        ) {
            @Dependency(\.calendar) var calendar
            @Dependency(\.universityCalendar) var universityCalendar
            @Dependency(\.date.now) var now

            self.offset = calendar.date(byAdding: .day, value: -1, to: now)
            self.pairRowDetails = pairRowDetails

            if let startDate, let endDate {
                self.weekSchedule = WeekSchedule(
                    schedule: schedule,
                    startDate: startDate,
                    endDate: endDate
                )
            }

            load(count: 12, calendar: calendar, universityCalendar: universityCalendar, now: now)
        }
    }
    
    public enum Action {
        case task
        case _loadMoreDays
        case scheduleList(ScheduleListFeature.Action)
    }
    
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.continuousClock) var clock
    @Dependency(\.calendar) var calendar
    @Dependency(\.universityCalendar) var universityCalendar
    @Dependency(\.date.now) var now

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                clipSchedule(upTo: now, state: &state)
                return .none
            case .scheduleList(.loadingIndicatorAppeared):
                return .run { send in
                    try await clock.sleep(for: .milliseconds(300))
                    await send(._loadMoreDays)
                }
                .cancellable(id: CancelID.loadDays, cancelInFlight: true)

            case ._loadMoreDays:
                state.load(count: 10, calendar: calendar, universityCalendar: universityCalendar, now: now)
                return .run { _ in
                    await reviewRequestService.madeMeaningfulEvent(.moreScheduleRequested)
                }

            case .scheduleList:
                return .none
            }
        }

        Scope(state: \.scheduleList, action: \.scheduleList) {
            ScheduleListFeature()
        }
    }

    private enum CancelID {
        case loadDays
    }
}

private extension MeaningfulEvent {
    static let moreScheduleRequested = Self(score: 1)
}
