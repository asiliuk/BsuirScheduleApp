import Foundation

public struct TermSchedule: Codable, Equatable {
    public let term: String?
    public let schedules: DaySchedule
}
