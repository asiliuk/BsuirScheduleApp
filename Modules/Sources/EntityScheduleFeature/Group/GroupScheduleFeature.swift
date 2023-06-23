import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import Favorites
import ComposableArchitecture

public struct GroupScheduleFeature: ReducerProtocol {
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
    
    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
            case showPremiumClubFakeAdsBanner
        }

        case schedule(ScheduleFeature<String>.Action)
        indirect case lectorSchedule(PresentationAction<LectorScheduleFeature.Action>)

        case lectorTapped(Employee)

        case delegate(DelegateAction)
    }

    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .lectorTapped(lector):
                state.lectorSchedule = .init(.init(lector: lector))
                return .none

            case let .schedule(.delegate(action)):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showPremiumClubFakeAdsBanner:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case let .lectorSchedule(.presented(.delegate(action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showPremiumClubFakeAdsBanner:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case .schedule, .lectorSchedule, .delegate:
                return .none
            }
        }
        .ifLet(\.$lectorSchedule, action: /Action.lectorSchedule) {
            LectorScheduleFeature()
        }
        
        Scope(state: \.schedule, action: /Action.schedule) {
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
