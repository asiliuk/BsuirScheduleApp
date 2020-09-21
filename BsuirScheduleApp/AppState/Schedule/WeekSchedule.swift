import Foundation
import BsuirApi

struct WeekSchedule {
    init(schedule: [DaySchedule], calendar: Calendar) {
        self.groupedSchedule = schedule.groupByRelativeWeekday()
        self.calendar = calendar
    }

    func pairs(for date: Date) -> [BsuirApi.Pair] {
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
    typealias ScheduleElement = (date: Date, pairs: [BsuirApi.Pair])
    func schedule(starting from: Date) -> AnySequence<ScheduleElement> {
        AnySequence { () -> AnyIterator<ScheduleElement> in
            var offset = 0
            return AnyIterator {
                guard let date = calendar.date(byAdding: .day, value: offset, to: from) else { return nil }
                offset += 1
                return (date: date, pairs: pairs(for: date))
            }
        }
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

        let dateWeekOfYear = component(.weekOfYear, from: date)
        let firstDateWeekOfYear = component(.weekOfYear, from: firstDay)

        return (abs(dateWeekOfYear - firstDateWeekOfYear) % 4) + 1
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
