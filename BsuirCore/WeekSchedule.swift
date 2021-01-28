import Foundation
import BsuirApi

public struct WeekSchedule {
    public init(schedule: [DaySchedule], calendar: Calendar) {
        self.groupedSchedule = schedule.groupByRelativeWeekday()
        self.calendar = calendar
    }

    public func pairs(for date: Date) -> [BsuirApi.Pair] {
        let components = calendar.dateComponents([.weekday], from: date)
        guard
            let weekday = components.weekday.flatMap(DaySchedule.WeekDay.init),
            let pairs = groupedSchedule[weekday]
        else {
            return []
        }

        return pairs
    }

    private let calendar: Calendar
    private let groupedSchedule: [DaySchedule.WeekDay: [BsuirApi.Pair]]
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
        AnySequence { () -> AnyIterator<ScheduleElement> in
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
                        .filter { $0.weekNumber.contains(weekNumber) }
                        .compactMap { pair -> ScheduleElement.Pair? in
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

private extension Array where Element == DaySchedule {
    func groupByRelativeWeekday() -> [DaySchedule.WeekDay: [BsuirApi.Pair]] {
        Dictionary(
            self
                .compactMap { day -> (DaySchedule.WeekDay, [BsuirApi.Pair])? in
                    switch day.weekDay {
                    case let .relative(weekDay):
                        return (weekDay, day.schedule)
                    case .date:
                        return nil
                    }
                },
            uniquingKeysWith: { _, rhs in assertionFailure(); return rhs }
        )
    }
}
