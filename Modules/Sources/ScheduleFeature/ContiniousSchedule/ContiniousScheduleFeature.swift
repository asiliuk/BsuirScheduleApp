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
            @Dependency(\.uuid) var uuid

            self.offset = calendar.date(byAdding: .day, value: -1, to: now)
            self.pairRowDetails = pairRowDetails

            if let startDate, let endDate {
                self.weekSchedule = WeekSchedule(
                    schedule: schedule,
                    startDate: startDate,
                    endDate: endDate
                )
            }

            load(count: 12, calendar: calendar, now: now, uuid: uuid)
        }
    }
    
    public enum Action: Equatable {
        case _loadMoreDays
        case scheduleList(ScheduleListFeature.Action)
    }
    
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.continuousClock) var clock
    @Dependency(\.calendar) var calendar
    @Dependency(\.date.now) var now
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .scheduleList(.loadingIndicatorAppeared):
                return .run { send in
                    try await clock.sleep(for: .milliseconds(300))
                    await send(._loadMoreDays)
                }
                .cancellable(id: CancelID.loadDays, cancelInFlight: true)

            case ._loadMoreDays:
                state.load(count: 10, calendar: calendar, now: now, uuid: uuid)
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

// MARK: - Load More

extension ContinuousScheduleFeature.State {
    mutating func load(count: Int, calendar: Calendar, now: Date, uuid: UUIDGenerator) {
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
                    uuid: uuid,
                    calendar: calendar,
                    now: now,
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
        uuid: UUIDGenerator,
        calendar: Calendar,
        now: Date,
        pairRowDetails: PairRowDetails?
    ) {
        self.init(
            id: uuid(),
            title: String(localized: "screen.schedule.day.title.\(element.date.formatted(.scheduleDay)).\(element.weekNumber)"),
            subtitle: Self.relativeFormatter.relativeName(for: element.date, now: now),
            isToday: calendar.isDateInToday(element.date),
            pairs: element.pairs.map(PairViewModel.init(pair:)),
            pairRowDetails: pairRowDetails,
            pairRowDay: .date(element.date)
        )
    }

    static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()
}
