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

    public init(days: [WeekDay: [Pair]] = [:]) {
        self.days = days
    }
    
    private let days: [WeekDay: [Pair]]
}

extension DaySchedule: Decodable {
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), container.decodeNil() {
            self.init()
            return
        }
        
        let container = try decoder.container(keyedBy: WeekDay.self)
        self.init(days: try Dictionary(
            uniqueKeysWithValues: container.allKeys.map { key in
                let pairs = try container.decode([Pair].self, forKey: key)
                return (key, pairs)
            }
        ))
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

extension DaySchedule.WeekDay {
    public var weekdayIndex: Int {
        switch self {
        case .sunday:
            return 0
        case .monday:
            return 1
        case .tuesday:
            return 2
        case .wednesday:
            return 3
        case .thursday:
            return 4
        case .friday:
            return 5
        case .saturday:
            return 6
        }
    }
}
