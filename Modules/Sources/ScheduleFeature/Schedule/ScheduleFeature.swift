import Foundation
import BsuirCore
import BsuirApi
import BsuirUI
import ScheduleCore
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils
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

        public init(title: String, source: ScheduleSource, value: Value) {
            self.title = title
            self.value = value
            self.mark = .init(source: source)
        }
    }

    public enum Action: Equatable, FeatureAction, LoadableAction {
        public enum ViewAction: Equatable {
            case setScheduleType(ScheduleDisplayType)
        }

        public enum ReducerAction: Equatable {
            case mark(MarkedScheduleFeature.Action)
        }

        public typealias DelegateAction = Never

        case loading(LoadingAction<State>)
        case schedule(LoadedScheduleReducer.Action)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    let fetch: @Sendable (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse
    @Dependency(\.reviewRequestService) var reviewRequestService
    
    public init(fetch: @Sendable @escaping (Value, _ ignoreCache: Bool) async throws -> ScheduleRequestResponse) {
        self.fetch = fetch
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(.setScheduleType(value)):
                defer { state.scheduleType = value }
                guard state.scheduleType != value else { return .none }
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.scheduleModeSwitched)
                }
                
            case .loading(.finished(\.$schedule)):
                if state.schedule?.continious.isEmpty == true {
                    state.scheduleType = .exams
                }
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.scheduleRequested)
                }

            case .schedule, .delegate, .loading, .reducer:
                return .none
            }
        }
        .load(\.$schedule, action: /Action.schedule) {
            LoadedScheduleReducer()
        } fetch: { state, isRefresh in
            try await LoadedScheduleReducer.State(response: fetch(state.value, isRefresh))
        }

        Scope(state: \State.mark, reducerAction: /Action.ReducerAction.mark) {
            MarkedScheduleFeature()
        }
    }
}

public struct LoadedScheduleReducer: Reducer {
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

    public var body: some ReducerOf<Self> {
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
