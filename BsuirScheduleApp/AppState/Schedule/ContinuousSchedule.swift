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
        self.weekSchedule = WeekSchedule(schedule: schedule, calendar: calendar, now: now)
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
            let weekNumber = calendar.weekNumber(for: date, now: now)
        else {
            return nil
        }

        let pairs = weekSchedule.pairs(for: date)
        guard !pairs.isEmpty else { return nil }

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

    private let now = Date()
    private var dayOffset: Int = -3
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
