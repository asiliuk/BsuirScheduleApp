import Foundation

public struct Employee: Codable, Equatable, Identifiable, Hashable {
    public let id: Int
    public let urlId: String
    
    public let firstName: String
    public let middleName: String?
    public let lastName: String

    public let rank: String?
    public let degree: String?
    public let academicDepartment: [String]?

    public let photoLink: URL?

    public init(
        id: Int,
        urlId: String,
        firstName: String,
        middleName: String?,
        lastName: String,
        rank: String?,
        degree: String?,
        academicDepartment: [String]?,
        photoLink: URL?
    ) {
        self.id = id
        self.urlId = urlId
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.photoLink = photoLink
        self.rank = rank
        self.degree = degree
        self.academicDepartment = academicDepartment
    }
}

extension Employee {
    public struct Schedule: Codable, Equatable {
        public let startDate: Date?
        public let endDate: Date?

        public let startExamsDate: Date?
        public let endExamsDate: Date?
        
        public let employee: Employee
        public let schedules: DaySchedule?
        public let previousSchedules: DaySchedule?
        public let nextSchedules: DaySchedule?
        public let examSchedules: [Pair]?
        
        private enum CodingKeys: String, CodingKey {
            case startDate
            case endDate
            case startExamsDate
            case endExamsDate
            case employee = "employeeDto"
            case schedules
            case previousSchedules
            case nextSchedules
            case examSchedules = "exams"
        }
    }
}

extension Employee.Schedule {
    /// Actual schedule of the group
    ///
    /// Sometimes API returns nil in `schedules` field:
    /// * at the end of current term, new schedule is passed in `nextSchedules`.
    /// * sometimes for unknown reason current schedule is passed as `previousSchedule`.
    /// This property allows to hide this complexity
    ///
    /// - Returns: Current schedule or next schedule or previous schedule.
    public var actualSchedule: DaySchedule {
        schedules.or(nextSchedules).or(previousSchedules).or(DaySchedule())
    }
}

extension Employee {
    /// Actual URL for employee photo
    ///
    /// Sometimes API returns no photo link or the one that has no host and starts with `null`
    /// In that case we fallback to static ID based URL
    /// This property allows to hide this complexity
    ///
    /// - Returns: URL of employee photo or hardcoded ID based photo URL.
    public var actualPhotoLink: URL? {
        if let photoLink, photoLink.host() != nil { return photoLink }
        return URL(string: "https://iis.bsuir.by/api/v1/employees/photo/\(id)")
    }
}

extension Employee {
    public var fio: String {
        return [lastName, firstName, middleName]
            .compactMap { name in
                guard let name = name, !name.isEmpty else { return nil }
                return name
            }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    public var compactFio: String {
        "\(lastName) \(firstName.prefix(1))\(middleName?.prefix(1) ?? "")"
    }

    // TODO: Use this to format titles inplace?
    public var nameComponents: PersonNameComponents {
        PersonNameComponents(givenName: firstName, middleName: middleName, familyName: lastName)
    }
}
