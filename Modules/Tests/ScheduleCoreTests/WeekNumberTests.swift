import XCTest
import BsuirCore
@testable import ScheduleCore

class WeekNumberTests: XCTestCase {
    var calendar: Calendar!

    override func setUpWithError() throws {
        calendar = .bsuir
    }

    override func tearDownWithError() throws {
        calendar = nil
    }

    func testWeekNumberAfterNewYear() throws {
        let now = try XCTUnwrap(DateFormatter.mock.date(from: "28.01.2021"))
        let tomorrow = try XCTUnwrap(DateFormatter.mock.date(from: "29.01.2021"))
        let nextMonday = try XCTUnwrap(DateFormatter.mock.date(from: "01.02.2021"))

        let tomorrowWeekNumber = calendar.weekNumber(for: tomorrow, now: now)
        let nextMondayWeekNumber = calendar.weekNumber(for: nextMonday, now: now)
        XCTAssertEqual(tomorrowWeekNumber, 2)
        XCTAssertEqual(nextMondayWeekNumber, 3)
    }

    func testWeekNumberOnFirstOfSeptember() throws {
        let now = try XCTUnwrap(DateFormatter.mock.date(from: "28.01.2021"))
        let date = try XCTUnwrap(DateFormatter.mock.date(from: "01.09.2020"))

        let weekNumber = calendar.weekNumber(for: date, now: now)
        XCTAssertEqual(weekNumber, 1)
    }

    func testWeekNumberOnNextWeekAfterFirstOfSeptember() throws {
        let now = try XCTUnwrap(DateFormatter.mock.date(from: "28.01.2021"))
        let date = try XCTUnwrap(DateFormatter.mock.date(from: "07.09.2020"))

        let weekNumber = calendar.weekNumber(for: date, now: now)
        XCTAssertEqual(weekNumber, 2)
    }

    func testWeekNumberOnDayBeforeFirstOfSeptember() throws {
        let now = try XCTUnwrap(DateFormatter.mock.date(from: "28.01.2021"))
        let date = try XCTUnwrap(DateFormatter.mock.date(from: "31.08.2020"))

        let weekNumber = calendar.weekNumber(for: date, now: now)
        XCTAssertEqual(weekNumber, 1)
    }

    func testWeekNumberOnSummerHolidays() throws {
        // Time goes backward on holidays
        let now = try XCTUnwrap(DateFormatter.mock.date(from: "15.07.2020"))
        var date = try XCTUnwrap(DateFormatter.mock.date(from: "30.08.2020"))

        var weekNumber = calendar.weekNumber(for: date, now: now)
        XCTAssertEqual(weekNumber, 2)

        date = try XCTUnwrap(DateFormatter.mock.date(from: "23.08.2020"))

        weekNumber = calendar.weekNumber(for: date, now: now)
        XCTAssertEqual(weekNumber, 3)
    }

    func testFirstDayToBeSunday() throws {
        let now = try XCTUnwrap(DateFormatter.mock.date(from: "15.07.2019"))
        var date = try XCTUnwrap(DateFormatter.mock.date(from: "01.09.2019"))

        var weekNumber = calendar.weekNumber(for: date, now: now)
        XCTAssertEqual(weekNumber, 1)

        date = try XCTUnwrap(DateFormatter.mock.date(from: "02.09.2019"))

        weekNumber = calendar.weekNumber(for: date, now: now)
        XCTAssertEqual(weekNumber, 2)
    }
}

private extension DateFormatter {
    static let mock = mutating(DateFormatter()) {
        $0.dateFormat = "dd.MM.yyyy"
    }
}
