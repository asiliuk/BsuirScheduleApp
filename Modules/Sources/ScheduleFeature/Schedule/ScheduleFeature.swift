import Foundation
import BsuirCore
import BsuirApi
import BsuirUI
import ScheduleCore
import LoadableFeature
import FakeAdsFeature
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

public struct ScheduleFeature<Value: Equatable>: ReducerProtocol {
    public struct State: Equatable {
        public var title: String
        public var value: Value
        public var mark: MarkedScheduleFeature.State
        public var isOnTop: Bool = true
        @LoadableState var schedule: LoadedScheduleReducer.State?
        var scheduleType: ScheduleDisplayType = .continuous
        var fakeAds: FakeAdsFeature.State = .init()
        var showFakeAds: Bool { mark.isPremiumLocked }

        public init(title: String, source: ScheduleSource, value: Value) {
            self.title = title
            self.value = value
            self.mark = .init(source: source)
        }
    }

    public enum Action: Equatable, LoadableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
            case showPremiumClubFakeAdsBanner
        }

        case mark(MarkedScheduleFeature.Action)
        case fakeAds(FakeAdsFeature.Action)
        case schedule(LoadedScheduleReducer.Action)

        case setScheduleType(ScheduleDisplayType)

        case loading(LoadingAction<State>)
        case delegate(DelegateAction)
    }

    let fetch: @Sendable (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse
    @Dependency(\.reviewRequestService) var reviewRequestService
    
    public init(fetch: @Sendable @escaping (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse) {
        self.fetch = fetch
    }
    
    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setScheduleType(value):
                defer { state.scheduleType = value }
                guard state.scheduleType != value else { return .none }
                return .fireAndForget {
                    await reviewRequestService.madeMeaningfulEvent(.scheduleModeSwitched)
                }
                
            case .loading(.finished(\.$schedule)):
                if state.schedule?.continious.isEmpty == true {
                    state.scheduleType = .exams
                }
                return .fireAndForget {
                    await reviewRequestService.madeMeaningfulEvent(.scheduleRequested)
                }

            case let .mark(.delegate(action)):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClubPinned))
                }

            case .fakeAds(.delegate(let action)):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case .schedule, .fakeAds, .mark, .delegate, .loading:
                return .none
            }
        }
        .load(\.$schedule, action: /Action.schedule) {
            LoadedScheduleReducer()
        } fetch: { state, isRefresh in
            try await LoadedScheduleReducer.State(response: fetch(state.value, isRefresh))
        }

        Scope(state: \State.mark, action: /Action.mark) {
            MarkedScheduleFeature()
        }

        Scope(state: \State.fakeAds, action: /Action.fakeAds) {
            FakeAdsFeature()
        }
    }
}

public struct LoadedScheduleReducer: ReducerProtocol {
    public struct State: Equatable {
        var compact: DayScheduleFeature.State
        var continious: ContiniousScheduleFeature.State
        var exams: ExamsScheduleFeature.State

        init(response: ScheduleRequestResponse) {
            self.compact = DayScheduleFeature.State(
                schedule: response.schedule
            )

            self.continious = ContiniousScheduleFeature.State(
                schedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate
            )

            self.exams = ExamsScheduleFeature.State(
                exams: response.exams,
                startDate: response.startExamsDate,
                endDate: response.endExamsDate
            )
        }
    }

    public enum Action: Equatable {
        case day(DayScheduleFeature.Action)
        case continious(ContiniousScheduleFeature.Action)
        case exams(ExamsScheduleFeature.Action)
    }

    public var body: some ReducerProtocolOf<Self> {
        Scope(state: \.compact, action: /Action.day) {
            DayScheduleFeature()
        }

        Scope(state: \.continious, action: /Action.continious) {
            ContiniousScheduleFeature()
        }

        Scope(state: \.exams, action: /Action.exams) {
            ExamsScheduleFeature()
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
            schedule?.compact.isOnTop = true
        case .exams:
            schedule?.exams.isOnTop = true
        case .continuous:
            schedule?.continious.isOnTop = true
        }
    }
}
