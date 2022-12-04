@testable import BsuirApi
import XCTest

final class StudentGroupTests: XCTestCase {

    func testScheduleParse_withOnlyExams() throws {
        // Given
        let data = try loadJson(named: "only_exams")

        // When
        let schedule = try JSONDecoder.bsuirDecoder.decode(StudentGroup.Schedule.self, from: data)

        // Then
        XCTAssertEqual(schedule.schedules.isEmpty, true)
    }
    
    func testScheduleParse_withNoStartEndLessonDates() throws {
        // Given
        let data = try loadJson(named: "no_start_end_lesson_date_on_exams")

        // When
        let schedule = try JSONDecoder.bsuirDecoder.decode(StudentGroup.Schedule.self, from: data)

        // Then
        XCTAssertEqual(schedule.schedules.isEmpty, false)
        XCTAssertEqual(schedule.examSchedules.isEmpty, false)
    }
    
    func testScheduleParse_withAnnouncement() throws {
        // Given
        let data = try loadJson(named: "with_announcement")

        // When
        let schedule = try JSONDecoder.bsuirDecoder.decode(StudentGroup.Schedule.self, from: data)

        // Then
        let announcement = try XCTUnwrap(schedule.schedules[.saturday]?.last)
        XCTAssertEqual(announcement.weekNumber, .always)
        XCTAssertTrue(announcement.announcement)
    }
}

// MARK: - Helpers

extension StudentGroupTests {
    func loadJson(named name: String) throws -> Data {
        let url = Bundle.module.url(forResource: name, withExtension: "json")
        return try Data(contentsOf: url!)
    }
}
