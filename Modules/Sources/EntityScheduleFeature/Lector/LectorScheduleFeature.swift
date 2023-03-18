import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import Favorites
import ComposableArchitecture
import ComposableArchitectureUtils

public struct LectorScheduleFeature: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: String { schedule.value }
        public let lector: Employee
        public var schedule: ScheduleFeature<String>.State
        @PresentationState var groupSchedule: GroupScheduleFeature.State?

        public init(lector: Employee) {
            self.schedule = .init(
                title: lector.compactFio,
                source: .lector(lector),
                value: lector.urlId
            )
            self.lector = lector
        }
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case groupTapped(String)
            case setGroupScheduleName(String?)
        }
        
        public enum ReducerAction: Equatable {
            case schedule(ScheduleFeature<String>.Action)
            indirect case groupSchedule(PresentationAction<GroupScheduleFeature.Action>)
        }
        
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
            case showPremiumClubFakeAdsBanner
        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(.groupTapped(groupName)):
                state.groupSchedule = .init(groupName: groupName)
                return .none

            case .view(.setGroupScheduleName(nil)):
                state.groupSchedule = nil
                return .none

            case .view(.setGroupScheduleName(.some)):
                assertionFailure("Unexpected")
                return .none

            case let .reducer(.schedule(.delegate(action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showPremiumClubFakeAdsBanner:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case let .reducer(.groupSchedule(.presented(.delegate(action)))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showPremiumClubFakeAdsBanner:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case .reducer, .delegate:
                return .none
            }
        }
        .ifLet(\.$groupSchedule, action: /Action.reducer .. /Action.ReducerAction.groupSchedule) {
            GroupScheduleFeature()
        }
        
        Scope(state: \.schedule, reducerAction: /Action.ReducerAction.schedule) {
            ScheduleFeature { urlId, isRefresh in
                try await ScheduleRequestResponse(response: apiClient.lecturerSchedule(urlId: urlId, ignoreCache: isRefresh))
            }
        }        
    }
}

// MARK: - Lector

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
