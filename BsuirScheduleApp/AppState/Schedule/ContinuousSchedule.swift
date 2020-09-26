import BsuirApi
import Combine
import Foundation
import os.log
import BsuirUI
import BsuirCore

final class ContinuousSchedule: ObservableObject {
    @Published private(set) var days: [Day] = []

    func loadMore() {
        self.loadMoreSubject.send()
    }

    init(schedule: [DaySchedule]) {
        self.weekSchedule = WeekSchedule(schedule: schedule, calendar: calendar)
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
        guard let offset = offset, let start = calendar.date(byAdding: .day, value: 1, to: offset) else { return }
        let days = Array(weekSchedule.schedule(starting: start, now: now).prefix(count))

        if mostRelevant == nil {
            mostRelevant = days.first { $0.hasUnfinishedPairs(calendar: calendar, now: now) }?.date
        }

        self.offset = days.last?.date
        self.days.append(contentsOf: days.map(self.day))
    }

    private func day(for element: WeekSchedule.ScheduleElement) -> Day {
        let title = "\(Self.formatter.string(from: element.date)), Неделя \(element.weekNumber)"
        let subtitle = relativeName(for: element.date)

        let pairProgress = { [calendar] pair in
            PairProgress(pair: pair, day: element.date, calendar: calendar) ?? PairProgress(constant: 0)
        }

        return Day(
            title: title,
            subtitle: subtitle,
            pairs: element.pairs.map { Day.Pair($0, showWeeks: false, progress: pairProgress($0)) },
            isToday: calendar.compare(now, to: element.date, toGranularity: .day) == .orderedSame,
            isMostRelevant: mostRelevant == element.date
        )
    }

    private func relativeName(for date: Date) -> String? {
        let components = calendar.dateComponents([.day], from: now, to: date)
        guard let day = components.day, -2...1 ~= day else { return nil }
        return Self.relativeFormatter.localizedString(from: components)
    }

    private let now = Date()
    private lazy var offset = calendar.date(byAdding: .day, value: -4, to: now)
    private var mostRelevant: Date?
    private let weekSchedule: WeekSchedule
    private let calendar = Calendar.current
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_BY")
        formatter.setLocalizedDateFormatFromTemplate("EEEdMMMM")
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

private extension WeekSchedule.ScheduleElement {
    func hasUnfinishedPairs(calendar: Calendar, now: Date) -> Bool {
        pairs.contains { pair in
            guard let pairEnd = calendar.date(bySetting: pair.endLessonTime, of: date) else { return false }
            return pairEnd > now
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
