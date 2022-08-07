//
//  Pair.swift
//  Pods
//
//  Created by Anton Siliuk on 07.03.17.
//

import Foundation

public struct Pair: Codable, Equatable {

    public enum Form : Equatable {
        case lecture
        case practice
        case lab
        case exam
        case unknown(String)
    }

    public struct Time : Equatable {
        public let hour: Int
        public let minute: Int
        public let timeZone: TimeZone?
    }
    
    public struct StudentGroup: Codable, Equatable {
        public let name: String
    }

    public let subject: String?
    public let subjectFullName: String?
    @NonEmpty public var auditories: [String]

    public let startLessonTime: Time
    public let endLessonTime: Time
    public let dateLesson: Date?
    
    public let subgroup: Int
    public let lessonType: Form?
    public let weekNumber: WeekNum
    public let note: String?

    @NonEmpty public var employees: [Employee]
    @NonEmpty public var studentGroups: [StudentGroup]
    
    private enum CodingKeys: String, CodingKey {
        case subject
        case subjectFullName
        case auditories
        case startLessonTime
        case endLessonTime
        case dateLesson
        case subgroup = "numSubgroup"
        case lessonType = "lessonTypeAbbrev"
        case weekNumber
        case note
        case employees
        case studentGroups
    }
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

extension Pair.Form: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self).lowercased()

        switch value {
        case "лк", "улк":
            self = .lecture
        case "пз", "упз":
            self = .practice
        case "лр", "улр":
            self = .lab
        case "экзамен":
            self = .exam
        case let unknown:
            self = .unknown(unknown)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .lecture:
            try container.encode("лк")
        case .practice:
            try container.encode("пз")
        case .lab:
            try container.encode("лр")
        case .exam:
            try container.encode("экзамен")
        case let .unknown(value):
            try container.encode(value)
        }
    }
}
