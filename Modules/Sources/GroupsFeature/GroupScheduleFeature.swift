import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import ComposableArchitecture

public struct GroupScheduleFeature: ReducerProtocol {
    public typealias State = ScheduleFeature<String>.State
    public typealias Action = ScheduleFeature<String>.Action

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        ScheduleFeature(
            target: { BsuirIISTargets.GroupSchedule(groupNumber: $0) },
            schedule: { ($0.schedules, $0.examSchedules) }
        )
    }
}

extension GroupScheduleFeature.State {
    public init(group: StudentGroup) {
        self.init(title: group.name, value: group.name)
    }
}
