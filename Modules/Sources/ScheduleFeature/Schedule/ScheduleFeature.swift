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

    public let lastUpdate: ScheduleLastUpdate

    public init(
        startDate: Date?,
        endDate: Date?,
        startExamsDate: Date?,
        endExamsDate: Date?,
        schedule: DaySchedule,
        exams: [BsuirApi.Pair],
        lastUpdate: ScheduleLastUpdate
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.startExamsDate = startExamsDate
        self.endExamsDate = endExamsDate
        self.schedule = schedule
        self.exams = exams
        self.lastUpdate = lastUpdate
    }
}

@Reducer
public struct ScheduleFeature<Value: Equatable> {
    @ObservableState
    public struct State {
        public var title: String
        public var value: Value
        public var mark: MarkedSchedulePickerFeature.State?
        var schedule: LoadingState<LoadedScheduleReducer.State> = .initial

        fileprivate var pairRowDetails: PairRowDetails?
        fileprivate var source: ScheduleSource
        var scheduleDisplayType: ScheduleDisplayType

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
            self.scheduleDisplayType = scheduleDisplayType
        }
    }

    public enum Action {
        public enum DelegateAction {
            case showPremiumClubPinned
            case showLectorSchedule(Employee)
            case showGroupSchedule(String)
        }

        case mark(MarkedSchedulePickerFeature.Action)
        case schedule(LoadingActionOf<LoadedScheduleReducer>)

        case delegate(DelegateAction)
    }

    let fetch: @Sendable (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.pinnedScheduleHashService) var pinnedScheduleHashService

    public init(fetch: @Sendable @escaping (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse) {
        self.fetch = fetch
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .schedule(.fetchFinished):
                return .merge(
                    .run { _ in await reviewRequestService.madeMeaningfulEvent(.scheduleRequested) },
                    updateScheduleLastKnownHash(source: state.source, response: state.schedule.loaded?.response)
                )

            case let .mark(.delegate(action)):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClubPinned))
                }

            case .schedule(.loaded(.continuous(.scheduleList(.delegate(let action))))),
                 .schedule(.loaded(.day(.scheduleList(.delegate(let action))))),
                 .schedule(.loaded(.exams(.scheduleList(.delegate(let action))))):
                switch action {
                case .loadMore:
                    return .none
                case .showGroupSchedule(let groupName):
                    return .send(.delegate(.showGroupSchedule(groupName)))
                case .showLectorSchedule(let employee):
                    return .send(.delegate(.showLectorSchedule(employee)))
                case .changeScheduleType(let displayType):
                    state.switchDisplayType(displayType)
                    return .none
                }

            case .schedule, .mark, .delegate:
                return .none
            }
        }
        .load(state: \.schedule, action: \.schedule) { state, isRefresh in
            try await LoadedScheduleReducer.State(
                source: state.source,
                response: fetch(state.value, isRefresh),
                pairRowDetails: state.pairRowDetails,
                scheduleDisplayType: state.scheduleDisplayType
            )
        } loaded: {
            LoadedScheduleReducer()
        }
        .ifLet(\.mark, action: \.mark) {
            MarkedSchedulePickerFeature()
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
}
