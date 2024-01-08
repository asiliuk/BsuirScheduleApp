import Foundation
import BsuirCore

public struct Pair: Codable, Equatable {

    public enum Form : Equatable {
        /// Лекция
        case lecture
        /// Практическое занятие
        case practice
        /// Лабораторное занятие
        case lab
        /// Консультация
        case consultation
        /// Экзамен
        case exam
        /// Зачет
        case test
        /// Неизвестно что
        case unknown(String)
    }

    public struct Time : Equatable {
        public let hour: Int
        public let minute: Int
        public let timeZone: TimeZone?
        
        public init(hour: Int = 0, minute: Int = 0, timeZone: TimeZone? = nil) {
            self.hour = hour
            self.minute = minute
            self.timeZone = timeZone
        }
    }
    
    public struct StudentGroup: Codable, Equatable {
        public let name: String
        
        public init(name: String) {
            self.name = name
        }
    }

    public let subject: String?
    public let subjectFullName: String?
    @NonEmpty public var auditories: [String]

    public let startLessonTime: Time
    public let startLessonDate: Date?
    public let endLessonTime: Time
    public let endLessonDate: Date?
    public let dateLesson: Date?
    
    public let subgroup: Int
    public let lessonType: Form?
    public let weekNumber: WeekNum
    public let note: String?

    @NonEmpty public var employees: [Employee]
    @NonEmpty public var studentGroups: [StudentGroup]
    
    public let announcementStart: String?
    public let announcementEnd: String?
    public let announcement: Bool
    
    private enum CodingKeys: String, CodingKey {
        case subject
        case subjectFullName
        case auditories
        case startLessonTime
        case startLessonDate
        case endLessonTime
        case endLessonDate
        case dateLesson
        case subgroup = "numSubgroup"
        case lessonType = "lessonTypeAbbrev"
        case weekNumber
        case note
        case employees
        case studentGroups
        
        case announcementStart
        case announcementEnd
        case announcement
    }
    
    public init(
        subject: String? = nil,
        subjectFullName: String? = nil,
        auditories: [String] = [],
        startLessonTime: Time = Time(),
        startLessonDate: Date? = nil,
        endLessonTime: Time = Time(),
        endLessonDate: Date? = nil,
        dateLesson: Date? = nil,
        subgroup: Int = 0,
        lessonType: Form? = .lecture,
        weekNumber: WeekNum = .always,
        note: String? = nil,
        employees: [Employee] = [],
        studentGroups: [StudentGroup] = [],
        announcementStart: String? = nil,
        announcementEnd: String? = nil,
        announcement: Bool = false
    ) {
        self.subject = subject
        self.subjectFullName = subjectFullName
        self._auditories = NonEmpty(wrappedValue: auditories)
        self.startLessonTime = startLessonTime
        self.startLessonDate = startLessonDate
        self.endLessonTime = endLessonTime
        self.endLessonDate = endLessonDate
        self.dateLesson = dateLesson
        self.subgroup = subgroup
        self.lessonType = lessonType
        self.weekNumber = weekNumber
        self.note = note
        self._employees = NonEmpty(wrappedValue: employees)
        self._studentGroups = NonEmpty(wrappedValue: studentGroups)
        self.announcementStart = announcementStart
        self.announcementEnd = announcementEnd
        self.announcement = announcement
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
        case "консультация":
            self = .consultation
        case "экзамен":
            self = .exam
        case "зачет":
            self = .test
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
        case .consultation:
            try container.encode("консультация")
        case .exam:
            try container.encode("экзамен")
        case .test:
            try container.encode("зачет")
        case let .unknown(value):
            try container.encode(value)
        }
    }
}
