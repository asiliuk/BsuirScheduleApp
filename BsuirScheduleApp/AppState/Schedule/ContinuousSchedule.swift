import BsuirApi
import Combine
import Foundation
import os.log
import BsuirUI
import BsuirCore

final class ContinuousSchedule: ObservableObject {
    @Published private(set) var days: [DayViewModel] = []

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

    private func day(for element: WeekSchedule.ScheduleElement) -> DayViewModel {
        return DayViewModel(
            title: "\(Self.formatter.string(from: element.date)), Неделя \(element.weekNumber)",
            subtitle: relativeName(for: element.date),
            pairs: element.pairs.map { PairViewModel(
                $0.base,
                showWeeks: false,
                progress: PairProgress(from: $0.start, to: $0.end)
            ) },
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
