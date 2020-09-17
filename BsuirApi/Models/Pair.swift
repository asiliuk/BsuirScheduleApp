//
//  Pair.swift
//  Pods
//
//  Created by Anton Siliuk on 07.03.17.
//

import Foundation

public struct Pair : Codable, Equatable {

    public enum Form : String, Equatable {
        case lecture  = "ЛК"
        case practice = "ПЗ"
        case lab      = "ЛР"
        case exam     = "Экзамен"
    }

    public struct Time : Equatable {
        public let hour: Int
        public let minute: Int
        public let timeZone: TimeZone?
    }

    public let subject: String
    @NonEmpty public var auditory: [String]

    public let startLessonTime: Time
    public let endLessonTime: Time

    public let numSubgroup: Int
    @Unknownable public var lessonType: Form?
    public let weekNumber: WeekNum
    public let note: String?

    public let zaoch: Bool

    @NonEmpty public var employee: [Employee]
}

extension Pair.Time : Codable {

    public enum Error: Swift.Error {
        case invalidFormat(String)
        case invalidValues(String?, String?)
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        let components = value.components(separatedBy: ":")
        guard components.count == 2 else { throw Error.invalidFormat(value) }

        guard
            let hour = components.first.flatMap({ Int($0) }),
            let minute = components.last.flatMap({ Int($0) })
        else { throw Error.invalidValues(components.first, components.last) }

        self = Pair.Time(hour: hour, minute: minute, timeZone: .minsk)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(hour):\(minute)")
    }
}

extension TimeZone {
    static let minsk = TimeZone(identifier: "Europe/Minsk")
}
