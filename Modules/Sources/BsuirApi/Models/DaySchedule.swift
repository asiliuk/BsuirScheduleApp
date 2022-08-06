import Foundation

public struct DaySchedule: Equatable {
    public enum WeekDay: String, Codable, Equatable, CodingKey, CaseIterable {
        case monday = "Понедельник"
        case tuesday = "Вторник"
        case wednesday = "Среда"
        case thursday = "Четверг"
        case friday = "Пятница"
        case saturday = "Суббота"
        case sunday = "Воскресенье"
    }
    
    public subscript(weekDay: WeekDay) -> [Pair]? {
        days[weekDay]
    }
    
    public var isEmpty: Bool {
        days.isEmpty
    }
    
    public init() {
        self.days = [:]
    }
    
    private let days: [WeekDay: [Pair]]
}

extension DaySchedule: Decodable {
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

extension DaySchedule: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WeekDay.self)
        for (weekDay, pairs) in days {
            try container.encode(pairs, forKey: weekDay)
        }
    }
}
