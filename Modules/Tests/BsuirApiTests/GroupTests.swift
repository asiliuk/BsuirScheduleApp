import Foundation
import Testing
@testable import BsuirApi

@Suite
struct StudentGroupTests {
    @Test
    func scheduleIsNil_withOnlyExams() throws {
        // Given
        let data = try loadJson(named: "only_exams")

        // When
        let schedule = try JSONDecoder.bsuirDecoder.decode(StudentGroup.Schedule.self, from: data)

        // Then
        #expect(schedule.schedules == nil)
    }

    @Test
    func scheduleParse_withNoStartEndLessonDates() throws {
        // Given
        let data = try loadJson(named: "no_start_end_lesson_date_on_exams")

        // When
        let schedule = try JSONDecoder.bsuirDecoder.decode(StudentGroup.Schedule.self, from: data)

        // Then
        #expect(schedule.schedules?.isEmpty == false)
        #expect(schedule.examSchedules.isEmpty == false)
    }

    @Test
    func scheduleParse_withAnnouncement() throws {
        // Given
        let data = try loadJson(named: "with_announcement")

        // When
        let schedule = try JSONDecoder.bsuirDecoder.decode(StudentGroup.Schedule.self, from: data)

        // Then
        let announcement = try #require(schedule.schedules?[.saturday]?.last)
        #expect(announcement.weekNumber == .always)
        #expect(announcement.announcement)
    }
}

// MARK: - Helpers

extension StudentGroupTests {
    func loadJson(named name: String) throws -> Data {
        let url = Bundle.module.url(forResource: name, withExtension: "json")
        return try Data(contentsOf: url!)
    }
}
