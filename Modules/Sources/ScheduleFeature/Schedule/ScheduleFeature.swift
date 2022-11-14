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
        public struct Schedule: Equatable {
            var compact: DayScheduleReducer.State

            init(schedule: DaySchedule, exams: [BsuirApi.Pair]) {
                compact = DayScheduleReducer.State(schedule: schedule)
            }
        }

        public var title: String
        public var value: Value
        @LoadableState var schedule: Schedule?
        
        public init(title: String, value: Value) {
            self.title = title
            self.value = value
        }
    }

    public enum Action: Equatable, FeatureAction, LoadableAction {
        public enum ViewAction {
            case task
        }

        public enum ReducerAction: Equatable {
            case daySchedule(DayScheduleReducer.Action)
        }

        public typealias DelegateAction = Never

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
            case .view(.task):
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.scheduleRequested)
                }
            case .reducer, .delegate, .loading:
                return .none
            }
        }
        .load(\.$schedule, action: (/Action.reducer).appending(path: /Action.ReducerAction.daySchedule)) {
            Scope(state: \.compact, action: .self) {
                DayScheduleReducer()
            }
        } fetch: { state in
            fetch(state.value)
        }
    }
}

private extension MeaningfulEvent {
    static let scheduleRequested = Self(score: 2)
    static let scheduleModeSwitched = Self(score: 3)
}
