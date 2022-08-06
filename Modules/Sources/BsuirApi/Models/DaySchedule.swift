//
//  DaySchedule.swift
//  Pods
//
//  Created by Anton Siliuk on 07.03.17.
//

import Foundation

public struct DaySchedule : Codable, Equatable {

    public enum WeekDay: String, Codable, Equatable, CodingKey, CaseIterable {
        case monday = "Понедельник"
        case tuesday = "Вторник"
        case wednesday = "Среда"
        case thursday = "Четверг"
        case friday = "Пятница"
        case saturday = "Суббота"
        case sunday = "Воскресенье"
    }

    public enum Day: Equatable {
        case relative(WeekDay)
        case date(Date)
    }

    public let weekDay: Day
    public let schedule: [Pair]
}

extension DaySchedule.Day : Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let date = try? container.decode(Date.self) {
            self = .date(date)
        } else {
            let value = try container.decode(String.self)
            guard let weekDay = DaySchedule.WeekDay(rawValue: value.capitalized) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected value for relative day")
            }
            self = .relative(weekDay)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .date(date):
            try container.encode(date)
        case let .relative(weekDay):
            try container.encode(weekDay.rawValue)
        }
    }
}
