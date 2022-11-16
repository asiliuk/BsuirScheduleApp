import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import ComposableArchitecture

public struct GroupScheduleFeature: ReducerProtocol {
    public struct GroupName: Equatable, Identifiable {
        public var id: String { name }
        let name: String
    }
    
    public typealias State = ScheduleFeature<GroupName>.State
    public typealias Action = ScheduleFeature<GroupName>.Action

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        ScheduleFeature(
            target: { BsuirIISTargets.GroupSchedule(groupNumber: $0.name) },
            schedule: { ($0.schedules, $0.examSchedules) }
        )
    }
}

extension GroupScheduleFeature.State {
    public init(group: StudentGroup) {
        self.init(title: group.name, value: .init(name: group.name))
    }
}

extension ScheduleFeature.State: Identifiable where Value: Identifiable {
    public var id: Value.ID { value.id }
}
