import BsuirApi
import Combine
import Foundation
import os.log

final class ContinuousSchedule: ObservableObject {
    @Published private(set) var days: [Day] = []

    func loadMore() {
        self.loadMoreSubject.send()
    }

    init(schedule: [DaySchedule]) {
        self.groupedSchedule = schedule.groupByRelativeWeekday()
        self.loadDays(12)

        self.loadMoreSubject
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] in
                os_log(.debug, "[ContinuousSchedule] Loading more days...")
                self?.loadDays(10)
            }
            .store(in: &cancellables)
    }

    private func loadDays(_ count: Int) {
        self.days.append(
            contentsOf: AnySequence {
                AnyIterator {
                    var newDay: Day?
                    var offset = self.dayOffset
                    repeat {
                        let isMostRelevant = self.dayOffset < 0 && offset >= 0
                        newDay = self.day(at: offset, isMostRelevant: isMostRelevant)
                        offset += 1
                    } while newDay == nil
                    self.dayOffset = offset
                    return newDay
                }
            }
            .prefix(count)
        )
    }

    private func day(at offset: Int, isMostRelevant: Bool) -> Day? {
        guard
            let date = calendar.date(byAdding: .day, value: offset, to: now),
            let (weekNumber, pairs) = pairs(for: date)
        else {
            return nil
        }

        let title = "\(Self.formatter.string(from: date)), Неделя \(weekNumber)"
        let subtitle = offset <= 1
            ? Self.relativeFormatter.localizedString(from: DateComponents(day: offset))
            : nil

        let pairProgress = { [calendar] pair in
            PairProgress(pair: pair, day: date, calendar: calendar) ?? PairProgress(constant: 0)
        }

        return Day(
            title: title,
            subtitle: subtitle,
            pairs: pairs.map { Day.Pair($0, showWeeks: false, progress: pairProgress($0)) },
            isToday: offset == 0,
            isMostRelevant: isMostRelevant
        )
    }

    private func pairs(for date: Date) -> (weekNumber: Int, [BsuirApi.Pair])? {
        let components = calendar.dateComponents([.weekday], from: date)
        guard
            let weekday = components.weekday.flatMap(DaySchedule.WeekDay.init),
            let rawWeekNumber = weekNumber(for: date),
            let weekNumber = WeekNum(weekNum: rawWeekNumber),
            let pairs = groupedSchedule[weekday]
        else {
            return nil
        }

        let weekDayPairs = pairs.filter { $0.weekNumber.contains(weekNumber) }

        guard !weekDayPairs.isEmpty else {
            return nil
        }

        return (weekNumber: rawWeekNumber, weekDayPairs)
    }

    private func weekNumber(for date: Date) -> Int? {
        let components = calendar.dateComponents([.day, .month, .year, .weekday], from: date)
        let firstDayComponents = mutating(components) { $0.day = 1; $0.month = 9 }
        let lastDayComponents = mutating(components) { $0.day = 1; $0.month = 7 }

        guard
            var firstDay = calendar.date(from: firstDayComponents),
            let lastDay = calendar.date(from: lastDayComponents)
        else {
            assertionFailure()
            return nil
        }

        if
            date < firstDay,
            now < lastDay,
            let newFirstDay = calendar.date(byAdding: .year, value: -1, to: firstDay)
        {
            firstDay = newFirstDay
        }

        let dateWeekOfYear = calendar.component(.weekOfYear, from: date)
        let firstDateWeekOfYear = calendar.component(.weekOfYear, from: firstDay)

        return (abs(dateWeekOfYear - firstDateWeekOfYear) % 4) + 1
    }

    private var dayOffset: Int = -3
    private let now = Date()
    private let calendar = Calendar.current
    private let groupedSchedule: [DaySchedule.WeekDay: [BsuirApi.Pair]]
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_BY")
        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        return formatter
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_BY")
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()
}

func mutating<Value>(_ value: Value, _ transform: (inout Value) -> Void) -> Value {
    var copy = value
    transform(&copy)
    return copy
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

private extension PairProgress {
    convenience init?(pair: BsuirApi.Pair, day: Date, calendar: Calendar) {
        guard
            let from = calendar.date(bySetting: pair.startLessonTime, of: day),
            let to = calendar.date(bySetting: pair.endLessonTime, of: day)
        else { return nil }

        self.init(from: from, to: to)
    }
}

private extension Calendar {
    func date(bySetting time: BsuirApi.Pair.Time, of date: Date) -> Date? {
        self.date(
            bySettingHour: time.hour,
            minute: time.minute,
            second: 0,
            of: date
        )
    }
}
