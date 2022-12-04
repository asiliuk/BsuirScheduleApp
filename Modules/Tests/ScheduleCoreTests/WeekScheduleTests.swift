@testable import BsuirCore
import XCTest
import BsuirApi

final class WeekScheduleTests: XCTestCase {
    let calendar = Calendar.current
    var daySchedule: DaySchedule!
    var schedule: WeekSchedule!
    var startDate: Date!
    var endDate: Date!
    
    let mondayPair1 = Pair(
        subject: "Monday Pair 1",
        startLessonTime: .init(hour: 9),
        endLessonTime: .init(hour: 10),
        weekNumber: .first
    )
    
    let tuesdayPair1 = Pair(
        subject: "Tuesday Pair 1",
        startLessonTime: .init(hour: 10, minute: 10),
        endLessonTime: .init(hour: 11, minute: 11),
        weekNumber: .oddWeeks
    )
    
    let tuesdayPair2 = Pair(
        subject: "Tuesday Pair 2",
        startLessonTime: .init(hour: 11, minute: 20),
        endLessonTime: .init(hour: 12, minute: 21),
        weekNumber: .evenWeeks
    )
    
    let saturdayPair1 = Pair(
        subject: "Saturday Pair 1",
        startLessonTime: .init(hour: 12),
        endLessonTime: .init(hour: 13),
        weekNumber: .always
    )

    override func setUp() {
        daySchedule = DaySchedule(days: [
            .monday: [mondayPair1],
            .tuesday: [tuesdayPair1, tuesdayPair2],
            .saturday: [saturdayPair1]
        ])
        
        startDate = date("17.11.2022")
        endDate = date("31.12.2022")
        
        schedule = WeekSchedule(
            schedule: daySchedule,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    override func tearDown() {
        schedule = nil
        daySchedule = nil
        startDate = nil
        endDate = nil
    }
    
    func testPairsForEmptyDayAreEmpty() {
        // Given
        let sunday = date("20.11.2022")
        
        // When
        let pairs = schedule.pairs(for: sunday, calendar: calendar)
        
        // Then
        XCTAssertEqual(pairs, [])
    }
    
    func testPairsForNonEmptyDayReturnPairs() {
        // Given
        let sunday = date("15.11.2022")
        
        // When
        let pairs = schedule.pairs(for: sunday, calendar: calendar)
        
        // Then
        XCTAssertEqual(pairs, daySchedule[.tuesday])
    }
    
    func testScheduleFiltersBasedOnWeekNumber() {
        // Given
        let from = date("21.11.2022")
        let now = date("17.11.2022")
        
        // When
        let schedule = schedule.schedule(starting: from, now: now, calendar: calendar)
        
        // Then
        XCTAssertEqual(calendar.weekNumber(for: from, now: now), 1)
        
        let firstWeek = Array(schedule.prefix(3))
        XCTAssertTrue(firstWeek.allSatisfy { $0.weekNumber == 1 })
        XCTAssertEqual(firstWeek[0].date, date("21.11.2022"))
        XCTAssertEqual(firstWeek[0].pairs, [.init(
            start: date("21.11.2022", time: "9:00"),
            end: date("21.11.2022", time: "10:00"),
            base: mondayPair1
        )])
        XCTAssertEqual(firstWeek[1].date, date("22.11.2022"))
        XCTAssertEqual(firstWeek[1].pairs, [.init(
            start: date("22.11.2022", time: "10:10"),
            end: date("22.11.2022", time: "11:11"),
            base: tuesdayPair1
        )])
        XCTAssertEqual(firstWeek[2].date, date("26.11.2022"))
        XCTAssertEqual(firstWeek[2].pairs, [.init(
            start: date("26.11.2022", time: "12:00"),
            end: date("26.11.2022", time: "13:00"),
            base: saturdayPair1
        )])
        
        let secondWeek = Array(schedule.dropFirst(3).prefix(2))
        XCTAssertTrue(secondWeek.allSatisfy { $0.weekNumber == 2 })
        XCTAssertEqual(secondWeek[0].date, date("29.11.2022"))
        XCTAssertEqual(secondWeek[0].pairs, [.init(
            start: date("29.11.2022", time: "11:20"),
            end: date("29.11.2022", time: "12:21"),
            base: tuesdayPair2
        )])
        XCTAssertEqual(secondWeek[1].date, date("03.12.2022"))
        XCTAssertEqual(secondWeek[1].pairs, [.init(
            start: date("03.12.2022", time: "12:00"),
            end: date("03.12.2022", time: "13:00"),
            base: saturdayPair1
        )])
    }
    
    func testScheduleEndsOnEndDate() {
        // Given
        let from = date("01.01.2023")
        let now = date("17.11.2022")
        
        // When
        let schedule = schedule.schedule(starting: from, now: now, calendar: calendar)
        
        // Then
        XCTAssertEqual(Array(schedule.prefix(10)), [])
    }

    func testScheduleHasPairsOnEndDate() throws {
        // Given
        startDate = date("17.11.2022")
        endDate = date("26.11.2022")

        schedule = WeekSchedule(
            schedule: daySchedule,
            startDate: startDate,
            endDate: endDate
        )

        let from = date("25.11.2022")
        let now = date("17.11.2022")

        // When
        let schedule = schedule.schedule(starting: from, now: now, calendar: calendar)

        // Then
        let element = try XCTUnwrap(Array(schedule.prefix(1)).first)
        XCTAssertEqual(element.date, date("26.11.2022"))
    }
    
    func testScheduleStartsOnStartDate() throws {
        // Given
        let from = date("01.01.2022")
        let now = date("17.11.2022")
        
        // When
        let schedule = schedule.schedule(starting: from, now: now, calendar: calendar)
        
        // Then
        let element = try XCTUnwrap(Array(schedule.prefix(1)).first)
        XCTAssertEqual(element.date, date("19.11.2022"))
    }
}

// MARK: - Helpers

private extension WeekScheduleTests {
    func date(_ date: String, time: String? = nil) -> Date {
        let value = [date, time].compactMap { $0 }.joined(separator: " ")
        return try! Date.FormatStyle(
            date: .numeric,
            time: time == nil ? .none : .shortened,
            locale: Locale(identifier: "ru_RU")
        ).parse(value)
    }
}
