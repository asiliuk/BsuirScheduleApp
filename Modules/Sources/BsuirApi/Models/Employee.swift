import Foundation

public struct Employee: Codable, Equatable, Identifiable, Hashable {
    public let id: Int
    public let urlId: String
    
    public let firstName: String
    public let middleName: String?
    public let lastName: String
    
    public let photoLink: URL?
}

extension Employee {
    public struct Schedule: Codable, Equatable {
        public let startDate: Date?
        public let endDate: Date?

        public let startExamsDate: Date?
        public let endExamsDate: Date?
        
        public let employee: Employee
        public let schedules: DaySchedule?
        public let examSchedules: [Pair]?
        
        private enum CodingKeys: String, CodingKey {
            case startDate
            case endDate
            case startExamsDate
            case endExamsDate
            case employee = "employeeDto"
            case schedules
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
