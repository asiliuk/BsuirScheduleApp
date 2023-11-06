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

        public init(
            groupName: String,
            showScheduleMark: Bool = true,
            scheduleDisplayType: ScheduleDisplayType = .continuous
        ) {
            self.schedule = .init(
                title: groupName,
                source: .group(name: groupName),
                value: groupName,
                pairRowDetails: .lecturers,
                showScheduleMark: showScheduleMark,
                scheduleDisplayType: scheduleDisplayType
            )
            self.groupName = groupName
        }
    }
    
    public enum Action: Equatable {
        case schedule(ScheduleFeature<String>.Action)
    }

    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerOf<Self> {
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
