import Foundation

public struct ScheduleLastUpdate: Equatable, Codable {
    public let lastUpdateDate: Date
}

extension StudentGroup.Schedule {
    public typealias LastUpdate = ScheduleLastUpdate
}

extension Employee.Schedule {
    public typealias LastUpdate = ScheduleLastUpdate
}
