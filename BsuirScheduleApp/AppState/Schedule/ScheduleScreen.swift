import BsuirApi
import Combine
import Foundation
import os.log
import BsuirUI
import BsuirCore

final class ScheduleScreen: ObservableObject {

    let name: String
    let schedule: LoadableContent<Schedule>
    @Published private(set) var isFavorite: Bool = false
    let toggleFavorite: () -> Void

    init(
        name: String,
        isFavorite: AnyPublisher<Bool, Never>,
        toggleFavorite: @escaping () -> Void,
        request: AnyPublisher<(schedule: [DaySchedule], exams: [DaySchedule]), RequestsManager.RequestError>
    ) {
        self.name = name
        self.schedule = LoadableContent(
            request
                .map(Schedule.init)
                .eraseToLoading()
        )

        self.toggleFavorite = toggleFavorite
        isFavorite.assign(to: &self.$isFavorite)
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
                .map { date in
                    guard date >= from else { return 0 }
                    guard date <= to else { return 1 }

                    let timeframe = to.timeIntervalSince(from)
                    guard timeframe > 0 else { return 0 }

                    return date.timeIntervalSince(from) / timeframe
                }
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
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
