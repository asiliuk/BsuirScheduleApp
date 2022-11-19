import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import Favorites
import ComposableArchitecture
import ComposableArchitectureUtils

public struct GroupScheduleFeature: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: String { schedule.value }
        public var schedule: ScheduleFeature<String>.State
        public let groupName: String

        // Has to be wrapped in the box or fails to compile because
        // of recursive state between group & lector schedule states
        @BindableState var lectorSchedule: Box<LectorScheduleFeature.State>?

        public init(groupName: String) {
            self.schedule = .init(title: groupName, value: groupName)
            self.groupName = groupName
        }
    }
    
    public enum Action: Equatable, FeatureAction, BindableAction {
        public enum ViewAction: Equatable {
            case task
            case lectorTapped(Employee)
        }
        
        public enum ReducerAction: Equatable {
            case schedule(ScheduleFeature<String>.Action)
            indirect case lectorSchedule(LectorScheduleFeature.Action)
            case updateIsFavorite(Bool)
        }
        
        public typealias DelegateAction = Never

        case binding(BindingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.favorites) var favorites

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                return .run { [groupName = state.groupName] send in
                    for await value in favorites.groupNames.values {
                        await send(.reducer(.updateIsFavorite(value.contains(groupName))))
                    }
                }

            case let .view(.lectorTapped(lector)):
                state.lectorSchedule = .init(.init(lector: lector))
                return .none

            case let .reducer(.updateIsFavorite(value)):
                state.schedule.isFavorite = value
                return .none

            case .reducer(.schedule(.delegate(.toggleFavorite))):
                return .fireAndForget { [groupName = state.groupName] in
                    favorites.toggle(groupNamed: groupName)
                }

            case .reducer, .binding:
                return .none
            }
        }
        .ifLet(\.lectorSchedule, action: (/Action.reducer).appending(path: /Action.ReducerAction.lectorSchedule)) {
            Scope(state: \.value, action: .self) {
                LectorScheduleFeature()
            }
        }
        
        Scope(state: \.schedule, action: /Action.ReducerAction.schedule) {
            ScheduleFeature(
                target: { BsuirIISTargets.GroupSchedule(groupNumber: $0) },
                schedule: ScheduleRequestResponse.init(response:)
            )
        }
        
        BindingReducer()
    }
}

private extension ScheduleRequestResponse {
    init(response: BsuirIISTargets.GroupSchedule.Value) {
        self.init(
            startDate: response.startDate,
            endDate: response.endDate,
            startExamsDate: response.startExamsDate,
            endExamsDate: response.endExamsDate,
            schedule: response.schedules,
            exams: response.examSchedules
        )
    }
}
