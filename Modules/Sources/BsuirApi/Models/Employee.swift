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
        public let examSchedules: [Pair]?
        
        private enum CodingKeys: String, CodingKey {
            case startDate
            case endDate
            case startExamsDate
            case endExamsDate
            case employee = "employeeDto"
            case schedules
            case previousSchedules
            case examSchedules = "exams"
        }
    }
}

extension Employee.Schedule {
    /// Actual schedule of the group
    ///
    /// Sometimes API returns nil in `schedules` field and current schedule is passed as `previousSchedule` for some reason. This property allows to hide this complexity
    ///
    /// - Returns: Current schedule or previous if current is empty
    public var actualSchedule: DaySchedule {
        schedules.or(previousSchedules).or(DaySchedule())
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
