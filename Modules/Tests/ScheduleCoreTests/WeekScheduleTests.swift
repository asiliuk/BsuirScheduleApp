@testable import ScheduleCore
import Foundation
import Testing
import BsuirApi

@Suite
struct WeekScheduleTests {
    let calendar = Calendar.current
    let daySchedule: DaySchedule
    var schedule: WeekSchedule

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

    init() {
        daySchedule = DaySchedule(days: [
            .monday: [mondayPair1],
            .tuesday: [tuesdayPair1, tuesdayPair2],
            .saturday: [saturdayPair1]
        ])

        schedule = WeekSchedule(
            schedule: daySchedule,
            startDate: Self.date("17.11.2022"),
            endDate: Self.date("31.12.2022")
        )
    }

    @Test
    func pairsForEmptyDayAreEmpty() {
        // Given
        let sunday = Self.date("20.11.2022")

        // When
        let pairs = schedule.pairs(for: sunday, calendar: calendar)
        
        // Then
        #expect(pairs == [])
    }

    @Test
    func pairsForNonEmptyDayReturnPairs() {
        // Given
        let sunday = Self.date("15.11.2022")

        // When
        let pairs = schedule.pairs(for: sunday, calendar: calendar)
        
        // Then
        #expect(pairs == daySchedule[.tuesday])
    }

    @Test
    func scheduleFiltersBasedOnWeekNumber() {
        // Given
        let from = Self.date("21.11.2022")
        let now = Self.date("17.11.2022")

        // When
        let schedule = schedule.schedule(starting: from, now: now, calendar: calendar, universityCalendar: calendar)

        // Then
        #expect(calendar.weekNumber(for: from, now: now) == 1)

        let firstWeek = Array(schedule.prefix(3))
        #expect(firstWeek.allSatisfy { $0.weekNumber == 1 })
        #expect(firstWeek[0].date == Self.date("21.11.2022"))
        #expect(firstWeek[0].pairs == [.init(
            start: Self.date("21.11.2022", time: "9:00"),
            end: Self.date("21.11.2022", time: "10:00"),
            base: mondayPair1
        )])
        #expect(firstWeek[1].date == Self.date("22.11.2022"))
        #expect(firstWeek[1].pairs == [.init(
            start: Self.date("22.11.2022", time: "10:10"),
            end: Self.date("22.11.2022", time: "11:11"),
            base: tuesdayPair1
        )])
        #expect(firstWeek[2].date == Self.date("26.11.2022"))
        #expect(firstWeek[2].pairs == [.init(
            start: Self.date("26.11.2022", time: "12:00"),
            end: Self.date("26.11.2022", time: "13:00"),
            base: saturdayPair1
        )])
        
        let secondWeek = Array(schedule.dropFirst(3).prefix(2))
        #expect(secondWeek.allSatisfy { $0.weekNumber == 2 })
        #expect(secondWeek[0].date == Self.date("29.11.2022"))
        #expect(secondWeek[0].pairs == [.init(
            start: Self.date("29.11.2022", time: "11:20"),
            end: Self.date("29.11.2022", time: "12:21"),
            base: tuesdayPair2
        )])
        #expect(secondWeek[1].date == Self.date("03.12.2022"))
        #expect(secondWeek[1].pairs == [.init(
            start: Self.date("03.12.2022", time: "12:00"),
            end: Self.date("03.12.2022", time: "13:00"),
            base: saturdayPair1
        )])
    }

    @Test
    func scheduleEndsOnEndDate() {
        // Given
        let from = Self.date("01.01.2023")
        let now = Self.date("17.11.2022")
        
        // When
        let schedule = schedule.schedule(starting: from, now: now, calendar: calendar, universityCalendar: calendar)

        // Then
        #expect(Array(schedule.prefix(10)) == [])
    }

    @Test
    mutating func scheduleHasPairsOnEndDate() throws {
        // Given
        let startDate = Self.date("17.11.2022")
        let endDate = Self.date("26.11.2022")

        schedule = WeekSchedule(
            schedule: daySchedule,
            startDate: startDate,
            endDate: endDate
        )

        let from = Self.date("25.11.2022")
        let now = Self.date("17.11.2022")

        // When
        let schedule = schedule.schedule(starting: from, now: now, calendar: calendar, universityCalendar: calendar)

        // Then
        let element = try #require(Array(schedule.prefix(1)).first)
        #expect(element.date == Self.date("26.11.2022"))
    }

    @Test
    func scheduleStartsOnStartDate() throws {
        // Given
        let from = Self.date("01.01.2022")
        let now = Self.date("17.11.2022")
        
        // When
        let schedule = schedule.schedule(starting: from, now: now, calendar: calendar, universityCalendar: calendar)
        
        // Then
        let element = try #require(Array(schedule.prefix(1)).first)
        #expect(element.date == Self.date("19.11.2022"))
    }
}

// MARK: - Helpers

private extension WeekScheduleTests {
    static func date(_ date: String, time: String? = nil) -> Date {
        let value = [date, time].compactMap { $0 }.joined(separator: " ")
        return try! Date.FormatStyle(
            date: .numeric,
            time: time == nil ? .none : .shortened,
            locale: Locale(identifier: "ru_RU")
        ).parse(value)
    }
}
