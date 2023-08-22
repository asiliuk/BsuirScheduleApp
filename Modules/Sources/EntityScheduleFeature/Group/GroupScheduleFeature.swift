import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import Favorites
import ComposableArchitecture

public struct GroupScheduleFeature: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: String { schedule.value }
        public var schedule: ScheduleFeature<String>.State
        public let groupName: String

        public init(groupName: String) {
            self.schedule = .init(title: groupName, source: .group(name: groupName), value: groupName)
            self.groupName = groupName
        }
    }
    
    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showPremiumClubPinned
            case showLectorSchedule(Employee)
        }

        case lectorTapped(Employee)
        case schedule(ScheduleFeature<String>.Action)
        case delegate(Delegate)
    }

    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .schedule(.delegate(action)):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                }

            case .lectorTapped(let employee):
                return .send(.delegate(.showLectorSchedule(employee)))

            case .schedule, .delegate:
                return .none
            }
        }
        
        Scope(state: \.schedule, action: /Action.schedule) {
            ScheduleFeature { name, isRefresh in
                try await ScheduleRequestResponse(response: apiClient.groupSchedule(name, isRefresh))
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
