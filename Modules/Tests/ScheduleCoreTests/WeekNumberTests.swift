import Testing
import Foundation
import BsuirCore
@testable import ScheduleCore

@Suite
struct WeekNumberTests {
    let calendar = Calendar.bsuir

    @Test
    func weekNumberAfterNewYear() throws {
        let now = try #require(DateFormatter.mock.date(from: "28.01.2021"))
        let tomorrow = try #require(DateFormatter.mock.date(from: "29.01.2021"))
        let nextMonday = try #require(DateFormatter.mock.date(from: "01.02.2021"))

        let tomorrowWeekNumber = calendar.weekNumber(for: tomorrow, now: now)
        let nextMondayWeekNumber = calendar.weekNumber(for: nextMonday, now: now)
        #expect(tomorrowWeekNumber == 2)
        #expect(nextMondayWeekNumber == 3)
    }

    @Test
    func weekNumberOnFirstOfSeptember() throws {
        let now = try #require(DateFormatter.mock.date(from: "28.01.2021"))
        let date = try #require(DateFormatter.mock.date(from: "01.09.2020"))

        let weekNumber = calendar.weekNumber(for: date, now: now)
        #expect(weekNumber == 1)
    }

    @Test
    func weekNumberOnNextWeekAfterFirstOfSeptember() throws {
        let now = try #require(DateFormatter.mock.date(from: "28.01.2021"))
        let date = try #require(DateFormatter.mock.date(from: "07.09.2020"))

        let weekNumber = calendar.weekNumber(for: date, now: now)
        #expect(weekNumber == 2)
    }

    @Test
    func weekNumberOnDayBeforeFirstOfSeptember() throws {
        let now = try #require(DateFormatter.mock.date(from: "28.01.2021"))
        let date = try #require(DateFormatter.mock.date(from: "31.08.2020"))

        let weekNumber = calendar.weekNumber(for: date, now: now)
        #expect(weekNumber == 1)
    }

    @Test
    func weekNumberOnSummerHolidays() throws {
        // Time goes backward on holidays
        let now = try #require(DateFormatter.mock.date(from: "15.07.2020"))
        var date = try #require(DateFormatter.mock.date(from: "30.08.2020"))

        var weekNumber = calendar.weekNumber(for: date, now: now)
        #expect(weekNumber == 2)

        date = try #require(DateFormatter.mock.date(from: "23.08.2020"))

        weekNumber = calendar.weekNumber(for: date, now: now)
        #expect(weekNumber == 3)
    }

    @Test
    func firstDayToBeSunday() throws {
        let now = try #require(DateFormatter.mock.date(from: "15.07.2019"))
        var date = try #require(DateFormatter.mock.date(from: "01.09.2019"))

        var weekNumber = calendar.weekNumber(for: date, now: now)
        #expect(weekNumber == 1)

        date = try #require(DateFormatter.mock.date(from: "02.09.2019"))

        weekNumber = calendar.weekNumber(for: date, now: now)
        #expect(weekNumber == 2)
    }
}

private extension DateFormatter {
    static let mock = mutating(DateFormatter()) {
        $0.dateFormat = "dd.MM.yyyy"
    }
}
