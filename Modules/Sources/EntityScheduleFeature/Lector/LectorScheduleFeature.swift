import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import Favorites
import ComposableArchitecture

public struct LectorScheduleFeature: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: String { schedule.value }
        public let lector: Employee
        public var schedule: ScheduleFeature<String>.State

        public init(lector: Employee) {
            self.schedule = .init(
                title: lector.compactFio,
                source: .lector(lector),
                value: lector.urlId
            )
            self.lector = lector
        }
    }
    
    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showPremiumClubPinned
            case showGroupSchedule(String)
        }

        case groupTapped(String)
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

            case .groupTapped(let name):
                return .send(.delegate(.showGroupSchedule(name)))

            case .schedule, .delegate:
                return .none
            }
        }
        
        Scope(state: \.schedule, action: /Action.schedule) {
            ScheduleFeature { urlId, isRefresh in
                try await ScheduleRequestResponse(response: apiClient.lecturerSchedule(urlId, isRefresh))
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
