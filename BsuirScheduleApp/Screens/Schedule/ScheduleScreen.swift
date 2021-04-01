import BsuirApi
import Combine
import Foundation
import os.log
import BsuirUI
import BsuirCore

final class ScheduleScreen: ObservableObject {
    enum ScheduleType: Hashable {
        case continuous
        case compact
        case exams
    }

    let name: String
    let schedule: LoadableContent<Schedule>
    @Published private(set) var isFavorite: Bool = false
    @Published var scheduleType: ScheduleType = .continuous
    let toggleFavorite: () -> Void
    let employeeSchedule: ((Employee) -> ScheduleScreen)?

    init(
        name: String,
        isFavorite: AnyPublisher<Bool, Never>,
        toggleFavorite: @escaping () -> Void,
        request: AnyPublisher<(schedule: [DaySchedule], exams: [DaySchedule]), RequestsManager.RequestError>,
        employeeSchedule: ((Employee) -> ScheduleScreen)?
    ) {
        self.employeeSchedule = employeeSchedule
        self.name = name
        self.schedule = LoadableContent(
            request
                .map(Schedule.init)
                .eraseToLoading()
        )

        self.toggleFavorite = toggleFavorite
        isFavorite.assign(to: &self.$isFavorite)

        self.schedule.$state
            .compactMap { $0.some }
            .first()
            .filter { schedule in
                schedule.continuous.days.isEmpty && !schedule.exams.isEmpty
            }
            .map { _ in .exams }
            .assign(to: &self.$scheduleType)
    }
}

extension ScheduleScreen {
    final class Schedule {
        let continuous: ContinuousSchedule
        let compact: [DayViewModel]
        let exams: [DayViewModel]

        init(schedule: [DaySchedule], exams: [DaySchedule]) {
            self.continuous = ContinuousSchedule(schedule: schedule)
            self.compact = schedule.map(DayViewModel.init)
            self.exams = exams.map(DayViewModel.init)
        }
    }
}

extension PairProgress {
    convenience init(from: Date, to: Date) {
        self.init(
            Timer
                .publish(every: 60, on: .main, in: .default)
                .autoconnect()
                .prepend(Date())
                .map { Self.progress(at: $0, from: from, to: to) }
                .eraseToAnyPublisher()
        )
    }
}

struct DayViewModel {
    var title: String
    var subtitle: String?
    var pairs: [PairViewModel]
    var isToday: Bool = false
    var isMostRelevant: Bool = false
}

extension DayViewModel {
    init(day: DaySchedule) {
        self.init(
            title: day.weekDay.title,
            pairs: day.schedule.map { PairViewModel($0) }
        )
    }
}

private extension DaySchedule.Day {

    var title: String {
        switch self {
        case let .date(date): return Self.formatter.string(from: date)
        case let .relative(weekDay): return weekDay.rawValue
        }
    }

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .by
        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        return formatter
    }()
}
