import Foundation
import BsuirCore
import BsuirApi
import BsuirUI
import ScheduleCore
import LoadableFeature
import ComposableArchitecture
import Dependencies

public struct ScheduleRequestResponse {
    public let startDate: Date?
    public let endDate: Date?

    public let startExamsDate: Date?
    public let endExamsDate: Date?

    public let schedule: DaySchedule
    public let exams: [BsuirApi.Pair]

    public init(
        startDate: Date?,
        endDate: Date?,
        startExamsDate: Date?,
        endExamsDate: Date?,
        schedule: DaySchedule,
        exams: [BsuirApi.Pair]
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.startExamsDate = startExamsDate
        self.endExamsDate = endExamsDate
        self.schedule = schedule
        self.exams = exams
    }
}

public struct ScheduleFeature<Value: Equatable>: Reducer {
    public struct State: Equatable {
        public var title: String
        public var value: Value
        public var mark: MarkedScheduleFeature.State
        public var isOnTop: Bool = true
        @LoadableState var schedule: LoadedScheduleReducer.State?
        var scheduleType: ScheduleDisplayType = .continuous
        var subgroupPicker: SubgroupPickerFeature.State?
        fileprivate var pairRowDetails: PairRowDetails?
        fileprivate var showSubgroupPicker: Bool
        fileprivate var source: ScheduleSource

        public init(
            title: String,
            source: ScheduleSource,
            value: Value,
            pairRowDetails: PairRowDetails?,
            showSubgroupPicker: Bool
        ) {
            self.source = source
            self.title = title
            self.value = value
            self.mark = .init(source: source)
            self.pairRowDetails = pairRowDetails
            self.showSubgroupPicker = showSubgroupPicker

            if showSubgroupPicker {
                @Dependency(\.subgroupFilterService) var subgroupFilterService
                let savedSubgroupSelection = subgroupFilterService.preferredSubgroup(source).value
                subgroupPicker = .init(maxSubgroup: 2, savedSelection: savedSubgroupSelection)
            }
        }
    }

    public enum Action: Equatable, LoadableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
            case showLectorSchedule(Employee)
            case showGroupSchedule(String)
        }

        case mark(MarkedScheduleFeature.Action)
        case schedule(LoadedScheduleReducer.Action)
        case subgroupPicker(SubgroupPickerFeature.Action)

        case setScheduleType(ScheduleDisplayType)

        case loading(LoadingAction<State>)
        case delegate(DelegateAction)
    }

    let fetch: @Sendable (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.subgroupFilterService) var subgroupFilterService

    public init(fetch: @Sendable @escaping (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse) {
        self.fetch = fetch
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \State.mark, action: /Action.mark) {
            MarkedScheduleFeature()
        }

        Reduce { state, action in
            switch action {
            case let .setScheduleType(value):
                defer { state.scheduleType = value }
                guard state.scheduleType != value else { return .none }
                return .run { _ in
                    await reviewRequestService.madeMeaningfulEvent(.scheduleModeSwitched)
                }
                
            case .loading(.finished(\.$schedule)):
                // Switch to exams if no regular schedule available
                if state.schedule?.continuous.hasSchedule == false {
                    state.scheduleType = .exams
                }

                // Show subgroup picker if needed
                if state.showSubgroupPicker, let maxSubgroup = state.schedule?.maxSubgroup {
                    state.subgroupPicker = SubgroupPickerFeature.State(
                        maxSubgroup: maxSubgroup,
                        savedSelection: subgroupFilterService.preferredSubgroup(state.source).value
                    )
                } else {
                    state.subgroupPicker = nil
                }

                return .run { _ in
                    await reviewRequestService.madeMeaningfulEvent(.scheduleRequested)
                }

            case let .mark(.delegate(action)):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClubPinned))
                }

            case .schedule(.continuous(.scheduleList(.delegate(let action)))),
                 .schedule(.day(.scheduleList(.delegate(let action)))),
                 .schedule(.exams(.scheduleList(.delegate(let action)))):
                switch action {
                case .loadMore:
                    return .none
                case .showGroupSchedule(let groupName):
                    return .send(.delegate(.showGroupSchedule(groupName)))
                case .showLectorSchedule(let employee):
                    return .send(.delegate(.showLectorSchedule(employee)))
                }

            case .schedule, .mark, .delegate, .loading, .subgroupPicker:
                return .none
            }
        }
        .load(\.$schedule, action: /Action.schedule) {
            LoadedScheduleReducer()
        } fetch: { state, isRefresh in
            try await LoadedScheduleReducer.State(
                response: fetch(state.value, isRefresh),
                pairRowDetails: state.pairRowDetails
            )
        }
        .ifLet(\.subgroupPicker, action: /Action.subgroupPicker) {
            SubgroupPickerFeature()
        }
        .onChange(of: \.subgroupPicker?.selected) { _, newValue in
            Reduce { state, _ in
                state.schedule?.filter(keepingSubgroup: newValue)
                return .run { [source = state.source] _ in
                    subgroupFilterService.preferredSubgroup(source).value = newValue ?? 0
                }
            }
        }
    }
}

private extension MeaningfulEvent {
    static let scheduleRequested = Self(score: 2)
    static let scheduleModeSwitched = Self(score: 3)
}

extension ScheduleFeature.State {
    public mutating func reset() {
        switch scheduleType {
        case .compact:
            schedule?.compact.reset()
        case .exams:
            schedule?.exams.reset()
        case .continuous:
            schedule?.continuous.reset()
        }
    }
}
