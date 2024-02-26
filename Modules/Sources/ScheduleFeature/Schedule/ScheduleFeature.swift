import Foundation
import BsuirCore
import BsuirApi
import BsuirUI
import ScheduleCore
import LoadableFeature
import ComposableArchitecture
import Dependencies
import CryptoKit

public struct ScheduleRequestResponse: Equatable, Encodable {
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

@Reducer
public struct ScheduleFeature<Value: Equatable> {
    public struct State: Equatable {
        public var title: String
        public var value: Value
        public var mark: MarkedSchedulePickerFeature.State?
        public var isOnTop: Bool = true
        var schedule: LoadableState<LoadedScheduleReducer.State> = .initial
        var scheduleType: ScheduleDisplayType
        var subgroupPicker: SubgroupPickerFeature.State?

        fileprivate var pairRowDetails: PairRowDetails?
        fileprivate var source: ScheduleSource

        public init(
            title: String,
            source: ScheduleSource,
            value: Value,
            pairRowDetails: PairRowDetails?,
            showScheduleMark: Bool,
            scheduleDisplayType: ScheduleDisplayType = .continuous
        ) {
            self.source = source
            self.title = title
            self.value = value
            self.mark = showScheduleMark ? .init(source: source) : nil
            self.pairRowDetails = pairRowDetails
            self.scheduleType = scheduleDisplayType

            @Dependency(\.subgroupFilterService) var subgroupFilterService
            let savedSubgroupSelection = subgroupFilterService.preferredSubgroup(source).value
            subgroupPicker = .init(maxSubgroup: 2, selected: savedSubgroupSelection)
        }
    }

    public enum Action: Equatable, LoadableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
            case showLectorSchedule(Employee)
            case showGroupSchedule(String)
        }

        case mark(MarkedSchedulePickerFeature.Action)
        case schedule(LoadedScheduleReducer.Action)
        case subgroupPicker(SubgroupPickerFeature.Action)

        case setScheduleType(ScheduleDisplayType)

        case loading(LoadingAction<State>)
        case delegate(DelegateAction)
    }

    let fetch: @Sendable (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.subgroupFilterService) var subgroupFilterService
    @Dependency(\.pinnedScheduleHashService) var pinnedScheduleHashService

    public init(fetch: @Sendable @escaping (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse) {
        self.fetch = fetch
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setScheduleType(value):
                defer { state.scheduleType = value }
                guard state.scheduleType != value else { return .none }
                return .run { _ in
                    await reviewRequestService.madeMeaningfulEvent(.scheduleModeSwitched)
                }
                
            case .loading(.finished(\.schedule)):
                // Switch to exams if no regular schedule available
                if state.schedule[case: \.some]?.continuous.hasSchedule == false {
                    state.scheduleType = .exams
                }

                // Show subgroup picker if needed
                if let maxSubgroup = state.schedule[case: \.some]?.maxSubgroup {
                    let savedSubgroupSelection = subgroupFilterService.preferredSubgroup(state.source).value
                    state.subgroupPicker = SubgroupPickerFeature.State(
                        maxSubgroup: maxSubgroup,
                        selected: savedSubgroupSelection
                    )

                    state.schedule.modify(\.some) { $0.filter(keepingSubgroup: savedSubgroupSelection) }
                } else {
                    state.subgroupPicker = nil
                }

                return .merge(
                    .run { _ in await reviewRequestService.madeMeaningfulEvent(.scheduleRequested) },
                    updateScheduleLastKnownHash(source: state.source, response: state.schedule[case: \.some]?.response)
                )

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
        .load(\.schedule, action: \.schedule) {
            LoadedScheduleReducer()
        } fetch: { state, isRefresh in
            try await LoadedScheduleReducer.State(
                response: fetch(state.value, isRefresh),
                pairRowDetails: state.pairRowDetails
            )
        }
        .ifLet(\.subgroupPicker, action: \.subgroupPicker) {
            SubgroupPickerFeature()
        }
        .ifLet(\.mark, action: \.mark) {
            MarkedSchedulePickerFeature()
        }
        .onChange(of: \.subgroupPicker?.selected) { _, newValue in
            Reduce { state, _ in
                state.schedule.modify(\.some) { $0.filter(keepingSubgroup: newValue) }
                return .run { [source = state.source] _ in
                    subgroupFilterService.preferredSubgroup(source).value = newValue
                }
            }
        }
    }

    private func updateScheduleLastKnownHash(
        source: ScheduleSource,
        response: ScheduleRequestResponse?
    ) -> Effect<Action> {
        return .run { _ in
            let hashStorage = pinnedScheduleHashService.lastKnownHash(source)
            guard let response else { return hashStorage.value = nil }

            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys

            let responseData = try encoder.encode(response)
            let responseHash = SHA256.hash(data: responseData).description
            hashStorage.value = responseHash
        }
    }
}

private extension MeaningfulEvent {
    static let scheduleRequested = Self(score: 2)
    static let scheduleModeSwitched = Self(score: 3)
}
