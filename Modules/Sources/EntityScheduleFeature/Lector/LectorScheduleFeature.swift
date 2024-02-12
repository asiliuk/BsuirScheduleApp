import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import Favorites
import ComposableArchitecture

@Reducer
public struct LectorScheduleFeature {
    public struct State: Equatable, Identifiable {
        public var id: String { schedule.value }
        public let lector: Employee
        public var schedule: ScheduleFeature<String>.State

        public init(
            lector: Employee,
            showScheduleMark: Bool = true,
            scheduleDisplayType: ScheduleDisplayType = .continuous
        ) {
            self.schedule = .init(
                title: lector.compactFio,
                source: .lector(lector),
                value: lector.urlId,
                pairRowDetails: .groups,
                showScheduleMark: showScheduleMark,
                scheduleDisplayType: scheduleDisplayType
            )
            self.lector = lector
        }
    }
    
    public enum Action: Equatable {
        case schedule(ScheduleFeature<String>.Action)
    }

    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.schedule, action: \.schedule) {
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
            schedule: response.actualSchedule,
            exams: response.examSchedules ?? []
        )
    }
}
