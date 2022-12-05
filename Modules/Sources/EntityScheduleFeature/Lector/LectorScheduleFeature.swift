import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import Favorites
import ComposableArchitecture
import ComposableArchitectureUtils

public struct LectorScheduleFeature: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: String { schedule.value }
        public let lector: Employee
        public var schedule: ScheduleFeature<String>.State
        @BindableState var groupSchedule: GroupScheduleFeature.State?

        public init(lector: Employee) {
            self.schedule = .init(title: lector.fio, value: lector.urlId)
            self.lector = lector
        }
    }
    
    public enum Action: Equatable, FeatureAction, BindableAction {
        public enum ViewAction: Equatable {
            case task
            case groupTapped(String)
        }
        
        public enum ReducerAction: Equatable {
            case schedule(ScheduleFeature<String>.Action)
            indirect case groupSchedule(GroupScheduleFeature.Action)
            case updateIsFavorite(Bool)
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
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .view(.task):
                return .run { [lector = state.lector] send in
                    for await value in favorites.lecturerIds.values {
                        await send(.reducer(.updateIsFavorite(value.contains(lector.id))))
                    }
                }

            case let .view(.groupTapped(groupName)):
                state.groupSchedule = .init(groupName: groupName)
                return .none

            case let .reducer(.updateIsFavorite(value)):
                state.schedule.isFavorite = value
                return .none

            case .reducer(.schedule(.delegate(.toggleFavorite))):
                return .fireAndForget { [id = state.lector.id] in
                    favorites.toggle(lecturerWithId: id)
                }

            case .reducer, .binding:
                return .none
            }
        }
        .ifLet(\.groupSchedule, action: (/Action.reducer).appending(path: /Action.ReducerAction.groupSchedule)) {
            GroupScheduleFeature()
        }
        
        Scope(state: \.schedule, action: /Action.ReducerAction.schedule) {
            ScheduleFeature { urlId, isRefresh in
                try await ScheduleRequestResponse(response: apiClient.lecturerSchedule(urlId: urlId, ignoreCache: isRefresh))
            }
        }        
    }
}

private extension ScheduleRequestResponse {
    init(response: Employee.Schedule) {
        self.init(
            startDate: response.startDate,
            endDate: response.endDate,
            startExamsDate: response.startExamsDate,
            endExamsDate: response.endExamsDate,
            schedule: response.schedules ?? DaySchedule(),
            exams: response.examSchedules ?? []
        )
    }
}
