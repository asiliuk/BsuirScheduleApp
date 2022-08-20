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

    init(schedule: DaySchedule, calendar: Calendar, now: Date) {
        self.calendar = calendar
        self.now = now
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
            subtitle: Self.relativeFormatter.relativeName(for: element.date, now: now),
            pairs: element.pairs.map(PairViewModel.init(pair:)),
            isToday: calendar.isDateInToday(element.date),
            isMostRelevant: mostRelevant == element.date
        )
    }

    private let now: Date
    private lazy var offset = calendar.date(byAdding: .day, value: -4, to: now)
    private var mostRelevant: Date?
    private let weekSchedule: WeekSchedule
    private let calendar: Calendar
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .by
        formatter.setLocalizedDateFormatFromTemplate("EEEdMMMM")
        return formatter
    }()

    private static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()
}
