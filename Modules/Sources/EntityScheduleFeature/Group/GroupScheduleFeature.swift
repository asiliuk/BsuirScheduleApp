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
            case updateIsPinned(Bool)
        }
        
        public typealias DelegateAction = Never

        case binding(BindingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites) var favorites

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                let groupName = state.groupName
                return .merge(
                    .run { send in
                        for await value in favorites.groupNames.values {
                            await send(.reducer(.updateIsFavorite(value.contains(groupName))))
                        }
                    },
                    .run { send in
                        for await value in favorites.pinnedSchedule.values {
                            await send(.reducer(.updateIsPinned(value?.isGroup(named: groupName) == true)))
                        }
                    }
                )

            case let .view(.lectorTapped(lector)):
                state.lectorSchedule = .init(.init(lector: lector))
                return .none

            case let .reducer(.updateIsFavorite(value)):
                state.schedule.isFavorite = value
                return .none

            case let .reducer(.updateIsPinned(value)):
                state.schedule.isPinned = value
                return .none

            case .reducer(.schedule(.delegate(.toggleFavorite))):
                return .fireAndForget { [groupName = state.groupName] in
                    favorites.toggle(groupNamed: groupName)
                }

            case .reducer(.schedule(.delegate(.togglePinned))):
                return .fireAndForget { [groupName = state.groupName] in
                    if let pinned = favorites.currentPinnedSchedule, pinned.isGroup(named: groupName) {
                        favorites.currentPinnedSchedule = nil
                    } else {
                        favorites.currentPinnedSchedule = .group(name: groupName)
                    }
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
            ScheduleFeature { name, isRefresh in
                try await ScheduleRequestResponse(response: apiClient.groupSchedule(name: name, ignoreCache: isRefresh))
            }
        }
        
        BindingReducer()
    }
}

private extension ScheduleRequestResponse {
    init(response: StudentGroup.Schedule) {
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
