import Foundation

public struct Employee: Codable, Equatable, Identifiable, Hashable {
    public let id: Int
    public let urlId: String
    
    public let firstName: String
    public let middleName: String?
    public let lastName: String
    
    public let photoLink: URL?

    public init(
        id: Int,
        urlId: String,
        firstName: String,
        middleName: String?,
        lastName: String,
        photoLink: URL?
    ) {
        self.id = id
        self.urlId = urlId
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.photoLink = photoLink
    }
}

extension Employee {
    public struct Schedule: Codable, Equatable {
        public let startDate: Date?
        public let endDate: Date?

        public let startExamsDate: Date?
        public let endExamsDate: Date?
        
        public let employee: Employee
        public let previousSchedules: TermSchedule?
        public let currentSchedules: TermSchedule?
        public let currentTerm: String?
        public let examSchedules: [Pair]?
        
        private enum CodingKeys: String, CodingKey {
            case startDate
            case endDate
            case startExamsDate
            case endExamsDate
            case employee = "employeeDto"
            case previousSchedules
            case currentSchedules
            case currentTerm = "currentPeriod"
            case examSchedules = "exams"
        }
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
