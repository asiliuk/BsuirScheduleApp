import Foundation
import BsuirApi

public struct WeekSchedule {
    public init(schedule: DaySchedule, calendar: Calendar) {
        self.schedule = schedule
        self.calendar = calendar
    }

    public func pairs(for date: Date) -> [BsuirApi.Pair] {
        let components = calendar.dateComponents([.weekday], from: date)
        guard
            let weekday = components.weekday.flatMap(DaySchedule.WeekDay.init(weekday:)),
            let pairs = schedule[weekday]
        else {
            return []
        }

        return pairs
    }

    private let calendar: Calendar
    private let schedule: DaySchedule
}

extension WeekSchedule {
    public struct ScheduleElement {
        public struct Pair {
            public let start: Date
            public let end: Date
            public let base: BsuirApi.Pair
        }

        public let date: Date
        public let weekNumber: Int
        public let pairs: [Pair]
    }

    public func schedule(starting start: Date, now: Date) -> AnySequence<ScheduleElement> {
        guard !schedule.isEmpty else {
            return AnySequence([])
        }

        return AnySequence { () -> AnyIterator<ScheduleElement> in
            var offset = 0
            return AnyIterator {
                var element: ScheduleElement?
                repeat {
                    guard
                        let date = calendar.date(byAdding: .day, value: offset, to: start),
                        let rawWeekNumber = calendar.weekNumber(for: date, now: now),
                        let weekNumber = WeekNum(weekNum: rawWeekNumber)
                    else { return nil }

                    let pairs = self.pairs(for: date)
                        .compactMap { pair -> ScheduleElement.Pair? in
                            guard
                                pair.weekNumber.contains(weekNumber),
                                let dateStart = calendar.startOfDay(for: date, in: .minsk),
                                (pair.startLessonDate...pair.endLessonDate).contains(dateStart)
                            else {
                                return nil
                            }
                            
                            guard
                                let start = calendar.date(bySetting: pair.startLessonTime, of: date),
                                let end = calendar.date(bySetting: pair.endLessonTime, of: date)
                            else { return nil }

                            return ScheduleElement.Pair(start: start, end: end, base: pair)
                        }

                    if !pairs.isEmpty {
                        element = ScheduleElement(
                            date: date,
                            weekNumber: rawWeekNumber,
                            pairs: pairs
                        )
                    }

                    offset += 1
                } while element == nil
                return element
            }
        }
    }
}

extension WeekSchedule.ScheduleElement {
    public func hasUnfinishedPairs(calendar: Calendar, now: Date) -> Bool {
        pairs.contains { $0.end > now }
    }
}

extension Calendar {
    public func date(bySetting time: BsuirApi.Pair.Time, of date: Date) -> Date? {
        self.date(
            bySettingHour: time.hour,
            minute: time.minute,
            second: 0,
            of: date
        )
    }
}

extension Calendar {
    func startOfDay(for date: Date, in timeZone: TimeZone?) -> Date? {
        var components = dateComponents([.day, .month, .year], from: date)
        components.timeZone = timeZone
        return self.date(from: components)
    }
    
    func weekNumber(for date: Date, now: Date) -> Int? {
        let components = dateComponents([.day, .month, .year, .weekday], from: date)
        let firstDayComponents = mutating(components) { $0.day = 1; $0.month = 9 }
        let lastDayComponents = mutating(components) { $0.day = 1; $0.month = 7 }

        guard
            var firstDay = self.date(from: firstDayComponents),
            let lastDay = self.date(from: lastDayComponents)
        else {
            assertionFailure()
            return nil
        }

        if
            date < firstDay,
            now < lastDay,
            let newFirstDay = self.date(byAdding: .year, value: -1, to: firstDay)
        {
            firstDay = newFirstDay
        }

        guard
            let distanceStart = startOfWeek(for: firstDay),
            let distanceEnd = startOfWeek(for: date),
            let weekOfYearDistance = dateComponents([.weekOfYear], from: distanceStart, to: distanceEnd).weekOfYear
        else {
            assertionFailure()
            return nil
        }

        return (abs(weekOfYearDistance) % 4) + 1
    }

    private func startOfWeek(for date: Date) -> Date? {
        let components = dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)
    }
}

private extension DaySchedule.WeekDay {
    init?(weekday: Int) {
        switch weekday {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }
}
