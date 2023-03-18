import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import Favorites
import ComposableArchitecture
import ComposableArchitectureUtils

public struct GroupScheduleFeature: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: String { schedule.value }
        public var schedule: ScheduleFeature<String>.State
        public let groupName: String
        @PresentationState var lectorSchedule: LectorScheduleFeature.State?

        public init(groupName: String) {
            self.schedule = .init(title: groupName, source: .group(name: groupName), value: groupName)
            self.groupName = groupName
        }
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case lectorTapped(Employee)
            case setLectorScheduleId(Int?)
        }
        
        public enum ReducerAction: Equatable {
            case schedule(ScheduleFeature<String>.Action)
            indirect case lectorSchedule(PresentationAction<LectorScheduleFeature.Action>)
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
            case let .view(.lectorTapped(lector)):
                state.lectorSchedule = .init(.init(lector: lector))
                return .none

            case .view(.setLectorScheduleId(nil)):
                state.lectorSchedule = nil
                return .none

            case .view(.setLectorScheduleId(.some)):
                assertionFailure("Not suppose to happen")
                return .none

            case let .reducer(.schedule(.delegate(action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showPremiumClubFakeAdsBanner:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case let .reducer(.lectorSchedule(.presented(.delegate(action)))):
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
        .ifLet(\.$lectorSchedule, action: /Action.reducer .. /Action.ReducerAction.lectorSchedule) {
            LectorScheduleFeature()
        }
        
        Scope(state: \.schedule, reducerAction: /Action.ReducerAction.schedule) {
            ScheduleFeature { name, isRefresh in
                try await ScheduleRequestResponse(response: apiClient.groupSchedule(name: name, ignoreCache: isRefresh))
            }
        }
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
