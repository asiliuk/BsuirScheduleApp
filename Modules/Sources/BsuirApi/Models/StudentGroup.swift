import Foundation

public struct StudentGroup: Codable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let course: Int?
    
    public init(id: Int, name: String, course: Int? = nil) {
        self.id = id
        self.name = name
        self.course = course
    }
}

extension StudentGroup {
    public struct Schedule: Codable, Equatable {
        public let startDate: Date?
        public let endDate: Date?

        public let startExamsDate: Date?
        public let endExamsDate: Date?

        public let studentGroup: StudentGroup

        public let schedules: DaySchedule
        public let examSchedules: [Pair]
        
        private enum CodingKeys: String, CodingKey {
            case startDate
            case endDate
            case startExamsDate
            case endExamsDate
            case studentGroup = "studentGroupDto"
            case schedules
            case examSchedules = "exams"
        }
    }
}
