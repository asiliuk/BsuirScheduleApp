import Foundation
import BsuirApi
import BsuirCore

public struct WeekSchedule: Equatable {
    public init(
        schedule: DaySchedule,
        startDate: Date,
        endDate: Date
    ) {
        self.schedule = schedule
        self.startDate = startDate
        self.endDate = endDate
    }

    public func pairs(for date: Date, calendar: Calendar) -> [BsuirApi.Pair] {
        let components = calendar.dateComponents([.weekday], from: date)
        guard
            let weekday = components.weekday.flatMap(DaySchedule.WeekDay.init(weekday:)),
            let pairs = schedule[weekday]
        else {
            return []
        }

        return pairs
    }

    private let schedule: DaySchedule
    private let startDate: Date
    private let endDate: Date
}

extension WeekSchedule {
    public struct ScheduleElement: Equatable {
        public struct Pair: Equatable {
            public let start: Date
            public let end: Date
            public let base: BsuirApi.Pair
        }

        public let date: Date
        public let weekNumber: Int
        public let pairs: [Pair]
    }

    public func schedule(
        starting start: Date,
        now: Date,
        calendar: Calendar
    ) -> AnySequence<ScheduleElement> {
        guard !schedule.isEmpty else {
            return AnySequence([])
        }

        return AnySequence { () -> AnyIterator<ScheduleElement> in
            var offset = 0
            return AnyIterator {
                var element: ScheduleElement?
                repeat {
                    defer { offset += 1 }

                    guard
                        let date = calendar.date(byAdding: .day, value: offset, to: start).map(calendar.startOfDay(for:)),
                        let rawWeekNumber = calendar.weekNumber(for: date, now: now),
                        let weekNumber = WeekNum(weekNum: rawWeekNumber),
                        calendar.isDate(date, inSameDayAs: endDate) || date < endDate
                    else {
                        // Break the sequence
                        return nil
                    }
                    
                    guard calendar.isDate(date, inSameDayAs: startDate) || date > startDate else {
                        continue
                    }

                    let pairs = self.pairs(for: date, calendar: calendar)
                        .compactMap { pair -> ScheduleElement.Pair? in
                            guard pair.weekNumber.contains(weekNumber) else {
                                return nil
                            }

                            if let dateLesson = pair.dateLesson, !calendar.isDate(dateLesson, inSameDayAs: date) {
                                return nil
                            } else if
                                let endLessonDate = pair.endLessonDate,
                                let startLessonDate = pair.startLessonDate,
                                !(startLessonDate...endLessonDate).contains(date)
                            {
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
                } while element == nil
                return element
            }
        }
    }
}

extension WeekSchedule.ScheduleElement {
    public func hasUnfinishedPairs(now: Date, subgroup: Int?) -> Bool {
        pairs
            .filter { $0.base.isSuitable(forSubgroup: subgroup) }
            .contains { $0.end > now }
    }
}

extension Pair {
    public func isSuitable(forSubgroup subgroup: Int?) -> Bool {
        guard self.subgroup != 0, let subgroup else { return true }
        return self.subgroup == subgroup
    }
}

extension Calendar {
    public func date(bySetting time: BsuirApi.Pair.Time, of date: Date) -> Date? {
        var components = dateComponents([.day, .month, .year], from: date)
        components.timeZone = time.timeZone
        components.hour = time.hour
        components.minute = time.minute
        components.second = 0
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
