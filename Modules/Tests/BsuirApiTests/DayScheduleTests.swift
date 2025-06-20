@testable import BsuirApi
import Foundation
import Testing

@Suite
struct DayScheduleTests {
    @Test
    func localizedWeekDayName_enUS() {
        // Given
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        
        // Then
        assert(weekday: .monday, nameIs: "Monday", in: calendar)
        assert(weekday: .tuesday, nameIs: "Tuesday", in: calendar)
        assert(weekday: .wednesday, nameIs: "Wednesday", in: calendar)
        assert(weekday: .thursday, nameIs: "Thursday", in: calendar)
        assert(weekday: .friday, nameIs: "Friday", in: calendar)
        assert(weekday: .saturday, nameIs: "Saturday", in: calendar)
        assert(weekday: .sunday, nameIs: "Sunday", in: calendar)
    }

    @Test
    func localizedWeekDayName_enNL() {
        // Given
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_NL")
        
        // Then
        assert(weekday: .monday, nameIs: "Monday", in: calendar)
        assert(weekday: .tuesday, nameIs: "Tuesday", in: calendar)
        assert(weekday: .wednesday, nameIs: "Wednesday", in: calendar)
        assert(weekday: .thursday, nameIs: "Thursday", in: calendar)
        assert(weekday: .friday, nameIs: "Friday", in: calendar)
        assert(weekday: .saturday, nameIs: "Saturday", in: calendar)
        assert(weekday: .sunday, nameIs: "Sunday", in: calendar)
    }

    @Test
    func localizedWeekDayName_enRU() {
        // Given
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_RU")
        
        // Then
        assert(weekday: .monday, nameIs: "Monday", in: calendar)
        assert(weekday: .tuesday, nameIs: "Tuesday", in: calendar)
        assert(weekday: .wednesday, nameIs: "Wednesday", in: calendar)
        assert(weekday: .thursday, nameIs: "Thursday", in: calendar)
        assert(weekday: .friday, nameIs: "Friday", in: calendar)
        assert(weekday: .saturday, nameIs: "Saturday", in: calendar)
        assert(weekday: .sunday, nameIs: "Sunday", in: calendar)
    }
}

// MARK: - Helpers

private extension DayScheduleTests {
    func assert(
        weekday: DaySchedule.WeekDay,
        nameIs expectedName: String,
        in calendar: Calendar,
        _ sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(weekday.localizedName(in: calendar) == expectedName, sourceLocation: sourceLocation)
    }
}
