import Foundation
import BsuirCore
import BsuirApi
import BsuirUI
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct ScheduleFeature<Value: Equatable>: ReducerProtocol {
    public struct State: Equatable {
        struct Schedule: Equatable {
            var compact: DayScheduleFeature.State
            var continious: ContiniousScheduleFeature.State
            var exams: ExamsScheduleFeature.State

            init(schedule: DaySchedule, exams: [BsuirApi.Pair]) {
                self.compact = DayScheduleFeature.State(schedule: schedule)
                self.continious = ContiniousScheduleFeature.State(schedule: schedule)
                self.exams = ExamsScheduleFeature.State(exams: exams)
            }
        }

        public var title: String
        public var value: Value
        @LoadableState var schedule: Schedule?
        @BindableState var scheduleType: ScheduleDisplayType = .continuous
        
        public init(title: String, value: Value) {
            self.title = title
            self.value = value
        }
    }

    public enum Action: Equatable, FeatureAction, BindableAction, LoadableAction {
        public enum ViewAction {
            case scrollToMostRelevantTapped
        }

        public enum ReducerAction: Equatable {
            public enum ScheduleAction: Equatable {
                case day(DayScheduleFeature.Action)
                case continious(ContiniousScheduleFeature.Action)
                case exams(ExamsScheduleFeature.Action)
            }
            
            case schedule(ScheduleAction)
        }

        public typealias DelegateAction = Never

        case binding(BindingAction<State>)
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
        schedule toSchedule: @escaping (Response) -> (schedule: DaySchedule, exams: [BsuirApi.Pair])
    ) {
        let requestsManager = _requestsManager.wrappedValue
        fetch = { state in
            .run { send in
                let request = requestsManager
                    .request(target(state))
                    .removeDuplicates()
                    .map(toSchedule)
                    .log(.appState, identifier: "Schedule")

                for try await (schedule, exams) in request.values {
                    await send(.success(State.Schedule(schedule: schedule, exams: exams)))
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
                
            case .loading(.finished(\.$schedule)):
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.scheduleRequested)
                }
                
            case .binding(\.$scheduleType):
                state.schedule?.continious.isOnTop = true
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.scheduleModeSwitched)
                }
            case .reducer, .delegate, .loading, .binding:
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
        
        BindingReducer()
    }
}

private extension MeaningfulEvent {
    static let scheduleRequested = Self(score: 2)
    static let scheduleModeSwitched = Self(score: 3)
}
