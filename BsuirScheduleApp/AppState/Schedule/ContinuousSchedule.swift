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
        let days = Array(
            weekSchedule.schedule(starting: start).lazy
                .compactMap { date, pairs in self.day(at: date, pairs: pairs).map { (date, $0) } }
                .prefix(count)
        )

        self.offset = days.last?.0
        self.days.append(contentsOf: days.map { $0.1 })
    }

    private func day(at date: Date, pairs: [BsuirApi.Pair]) -> Day? {
        guard
            let weekNumber = calendar.weekNumber(for: date, now: now),
            let weekNum = WeekNum(weekNum: weekNumber)
        else { return nil }

        let pairs = weekSchedule.pairs(for: date).filter { $0.weekNumber.contains(weekNum) }
        guard !pairs.isEmpty else { return nil }

        let title = "\(Self.formatter.string(from: date)), Неделя \(weekNumber)"
        let subtitle = relativeName(for: date)

        let pairProgress = { [calendar] pair in
            PairProgress(pair: pair, day: date, calendar: calendar) ?? PairProgress(constant: 0)
        }

        return Day(
            title: title,
            subtitle: subtitle,
            pairs: pairs.map { Day.Pair($0, showWeeks: false, progress: pairProgress($0)) },
            isToday: calendar.compare(now, to: date, toGranularity: .day) == .orderedSame,
            isMostRelevant: false
        )
    }

    private func relativeName(for date: Date) -> String? {
        let components = calendar.dateComponents([.day], from: now, to: date)
        guard let day = components.day, -2...1 ~= day else { return nil }
        return Self.relativeFormatter.localizedString(from: components)
    }

    private let now = Date()
    private lazy var offset = calendar.date(byAdding: .day, value: -4, to: now)
    private let weekSchedule: WeekSchedule
    private let calendar = Calendar.current
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
