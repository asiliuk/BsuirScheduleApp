import Foundation
import BsuirCore
import BsuirApi
import BsuirUI
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

public struct ScheduleFeature<Value: Equatable>: ReducerProtocol {
    public struct State: Equatable {
        struct Schedule: Equatable {
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

        public var title: String
        public var value: Value
        public var isFavorite: Bool = false
        @LoadableState var schedule: Schedule?
        var scheduleType: ScheduleDisplayType = .continuous
        
        public init(title: String, value: Value) {
            self.title = title
            self.value = value
        }
    }

    public enum Action: Equatable, FeatureAction, LoadableAction {
        public enum ViewAction: Equatable {
            case scrollToMostRelevantTapped
            case toggleFavoritesTapped
            case setScheduleType(ScheduleDisplayType)
        }

        public enum ReducerAction: Equatable {
            public enum ScheduleAction: Equatable {
                case day(DayScheduleFeature.Action)
                case continious(ContiniousScheduleFeature.Action)
                case exams(ExamsScheduleFeature.Action)
            }
            
            case schedule(ScheduleAction)
        }

        public enum DelegateAction: Equatable {
            case toggleFavorite
        }

        case loading(LoadingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    let fetch: (Value) -> EffectTask<TaskResult<State.Schedule>>
    @Dependency(\.requestsManager) var requestsManager
    @Dependency(\.reviewRequestService) var reviewRequestService
    
    public init<Response: Equatable>(
        target: @escaping (Value) -> some Target<Response>,
        schedule toSchedule: @escaping (Response) -> ScheduleRequestResponse
    ) {
        let requestsManager = _requestsManager.wrappedValue
        fetch = { state in
            .run { send in
                let request = requestsManager
                    .request(target(state))
                    .removeDuplicates()
                    .map(toSchedule)
                    .log(.appState, identifier: "Schedule")

                for try await response in request.values {
                    await send(.success(State.Schedule(response: response)))
                }
            } catch: { error, send in
                await send(.failure(error))
            }
        }
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.scrollToMostRelevantTapped):
                state.schedule?.continious.isOnTop = true
                return .none

            case let .view(.setScheduleType(value)):
                defer { state.scheduleType = value }
                guard state.scheduleType != value else { return .none }

                state.schedule?.continious.isOnTop = true
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.scheduleModeSwitched)
                }
                
            case .loading(.finished(\.$schedule)):
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.scheduleRequested)
                }

            case .view(.toggleFavoritesTapped):
                return .merge(
                    .task { .delegate(.toggleFavorite) },
                    .fireAndForget { [isFavorite = state.isFavorite] in
                        guard !isFavorite else { return }
                        reviewRequestService.madeMeaningfulEvent(.addToFavorites)
                    }
                )

            case .reducer, .delegate, .loading:
                return .none
            }
        }
        .load(
            \.$schedule,
             action: (/Action.reducer).appending(path: /Action.ReducerAction.schedule)
        ) {
            Scope(state: \.compact, action: /Action.ReducerAction.ScheduleAction.day) {
                DayScheduleFeature()
            }
            
            Scope(state: \.continious, action: /Action.ReducerAction.ScheduleAction.continious) {
                ContiniousScheduleFeature()
            }
            Scope(state: \.exams, action: /Action.ReducerAction.ScheduleAction.exams) {
                ExamsScheduleFeature()
            }
        } fetch: { state in
            fetch(state.value)
        }
    }
}

private extension MeaningfulEvent {
    static let scheduleRequested = Self(score: 2)
    static let scheduleModeSwitched = Self(score: 3)
    static let addToFavorites = Self(score: 5)
}
