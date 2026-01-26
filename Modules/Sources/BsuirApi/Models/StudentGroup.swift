import Foundation

public struct StudentGroup: Codable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let course: Int?
    public let faculty: String
    public let speciality: String
    
    public init(
        id: Int,
        name: String,
        course: Int? = nil,
        faculty: String,
        speciality: String
    ) {
        self.id = id
        self.name = name
        self.course = course
        self.faculty = faculty
        self.speciality = speciality
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case course
        case faculty = "facultyAbbrev"
        case speciality = "specialityAbbrev"
    }
}

extension StudentGroup {
    public struct Schedule: Codable, Equatable {
        public let startDate: Date?
        public let endDate: Date?

        public let startExamsDate: Date?
        public let endExamsDate: Date?

        public let studentGroup: StudentGroup

        public let schedules: DaySchedule?
        public let previousSchedules: DaySchedule?
        public let nextSchedules: DaySchedule?
        public let examSchedules: [Pair]
        
        private enum CodingKeys: String, CodingKey {
            case startDate
            case endDate
            case startExamsDate
            case endExamsDate
            case studentGroup = "studentGroupDto"
            case schedules
            case previousSchedules
            case nextSchedules
            case examSchedules = "exams"
        }
    }
}

extension StudentGroup.Schedule {
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
