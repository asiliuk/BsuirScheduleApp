import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import ComposableArchitecture

public struct LectorScheduleFeature: ReducerProtocol {
    public struct LectorUrlId: Equatable, Identifiable {
        public var id: String { urlId }
        let urlId: String
    }
    public typealias State = ScheduleFeature<LectorUrlId>.State
    public typealias Action = ScheduleFeature<LectorUrlId>.Action

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        ScheduleFeature(
            target: { BsuirIISTargets.EmployeeSchedule(urlId: $0.urlId) },
            schedule: { ($0.schedules ?? DaySchedule(), $0.examSchedules ?? []) }
        )
    }
}

extension LectorScheduleFeature.State {
    public init(lector: Employee) {
        self.init(title: lector.fio, value: .init(urlId: lector.urlId))
    }
}
