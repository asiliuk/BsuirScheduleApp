import Foundation

public struct WeekScheduleDto: Equatable {
    public typealias WeekDay = DaySchedule.WeekDay
    public let days: [WeekDay: [Pair]]
}

extension WeekScheduleDto: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WeekDay.self)
        self.days = try Dictionary(
            uniqueKeysWithValues: container.allKeys.map { key in
                let pairs = try container.decode([Pair].self, forKey: key)
                return (key, pairs)
            }
        )
    }
}

extension WeekScheduleDto: Encodable {
    public func encode(to encoder: Encoder) throws {
        fatalError("Unimplemented")
    }
}

extension WeekScheduleDto {
    public var daySchedules: [DaySchedule] {
        days
            .sorted { lhs, rhs in
                guard
                    let lhsIdx = WeekDay.allCases.firstIndex(of: lhs.key),
                    let rhsIdx = WeekDay.allCases.firstIndex(of: rhs.key)
                else {
                    assertionFailure("Failed to find key index")
                    return false
                }
                
                return lhsIdx < rhsIdx
            }
            .map { weekDay, schedule in
                DaySchedule(weekDay: .relative(weekDay), schedule: schedule)
            }
    }
}
