import Foundation
import BsuirCore
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

public struct ContinuousScheduleFeature: Reducer {
    public struct State: Equatable {
        public var hasSchedule: Bool { scheduleList.hasSchedule }

        var scheduleList = ScheduleListFeature.State(days: [], loading: .loadMore)

        private var offset: Date?
        private var weekSchedule: WeekSchedule?
        private var pairRowDetails: PairRowDetails?

        init(
            schedule: DaySchedule,
            startDate: Date?,
            endDate: Date?,
            pairRowDetails: PairRowDetails?
        ) {
            @Dependency(\.calendar) var calendar
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

            load(count: 12, calendar: calendar, now: now)
        }
    }
    
    public enum Action: Equatable {
        case task
        case _loadMoreDays
        case scheduleList(ScheduleListFeature.Action)
    }
    
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.continuousClock) var clock
    @Dependency(\.calendar) var calendar
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
                state.load(count: 10, calendar: calendar, now: now)
                return .run { _ in
                    await reviewRequestService.madeMeaningfulEvent(.moreScheduleRequested)
                }

            case .scheduleList:
                return .none
            }
        }

        Scope(state: \.scheduleList, action: /Action.scheduleList) {
            ScheduleListFeature()
        }
    }

    private enum CancelID {
        case loadDays
    }
}

extension ContinuousScheduleFeature.State {
    public mutating func reset() {
        scheduleList.isOnTop = true
    }
}

private extension MeaningfulEvent {
    static let moreScheduleRequested = Self(score: 1)
}

// MARK: - Filter

extension ContinuousScheduleFeature.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        scheduleList.filter(keepingSubgroup: subgroup)
    }
}

// MARK: - Helpers

private extension ContinuousScheduleFeature {
    func clipSchedule(upTo clippingDate: Date, state: inout State) {
        // Find index of a day who's date is today or in the future
        guard let firstScheduleDayIndex = state.scheduleList.days.firstIndex(where: { state in
            guard case .continuousDate(let date, _) = state.dayDate else { return false }
            return calendar.isDate(date, inSameDayAs: clippingDate) || date > clippingDate
        }) else { return }

        // Remove all days that have passed
        state.scheduleList.days.removeFirst(firstScheduleDayIndex)

        // Load more schedule if clipping almost all
        if state.scheduleList.days.count <= 4 {
            state.load(count: 10, calendar: calendar, now: now)
        }
    }
}

private extension ContinuousScheduleFeature.State {
    mutating func load(count: Int, calendar: Calendar, now: Date) {
        guard
            let weekSchedule = weekSchedule,
            let offset = offset,
            let start = calendar.date(byAdding: .day, value: 1, to: offset)
        else { return }

        let days = Array(weekSchedule.schedule(starting: start, now: now, calendar: calendar).prefix(count))
        scheduleList.loading = (days.count < count) ? .finished : .loadMore

        self.offset = days.last?.date
        scheduleList.days.append(
            contentsOf: days.map { element in
                DaySectionFeature.State(
                    element: element,
                    pairRowDetails: pairRowDetails
                )
            }
        )
    }
}

// MARK: - DaySectionFeature

private extension DaySectionFeature.State {
    init(
        element: WeekSchedule.ScheduleElement,
        pairRowDetails: PairRowDetails?
    ) {
        self.init(
            dayDate: .continuousDate(element.date, weekNumber: element.weekNumber),
            pairs: element.pairs.map(PairViewModel.init(pair:)),
            pairRowDetails: pairRowDetails,
            pairRowDay: .date(element.date)
        )
    }
}
