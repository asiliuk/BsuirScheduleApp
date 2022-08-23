import BsuirApi
import Combine
import Foundation
import os.log
import BsuirUI
import BsuirCore

final class ScheduleScreen: ObservableObject {
    enum ScheduleType: Hashable, CaseIterable {
        case continuous
        case compact
        case exams
    }

    let name: String
    let schedule: LoadableContent<Schedule>
    @Published private(set) var isFavorite: Bool = false
    @Published var scheduleType: ScheduleType = .continuous
    let toggleFavorite: (() -> Void)?
    let employeeSchedule: ((Employee) -> ScheduleScreen)?
    let groupSchedule: ((String) -> ScheduleScreen)?

    init(
        name: String,
        isFavorite: AnyPublisher<Bool, Never>,
        toggleFavorite: (() -> Void)?,
        request: AnyPublisher<(schedule: DaySchedule, exams: [BsuirApi.Pair]), RequestsManager.RequestError>,
        employeeSchedule: ((Employee) -> ScheduleScreen)?,
        groupSchedule: ((String) -> ScheduleScreen)?
    ) {
        self.employeeSchedule = employeeSchedule
        self.groupSchedule = groupSchedule
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
        let compact: DayScheduleViewModel
        let exams: [DayViewModel]
        private let calendar = Calendar.current
        private let now = Date()

        init(schedule: DaySchedule, exams: [Pair]) {
            self.continuous = ContinuousSchedule(schedule: schedule, calendar: calendar, now: now)
            self.compact = DayScheduleViewModel(schedule: schedule, calendar: calendar, now: now)
            // TODO: Support exams once again
            self.exams = [
                DayViewModel(
                    title: String(localized: "My deepest apologies"),
                    pairs: [
                        PairViewModel(
                            from: "🚧", to: " ",
                            form: .unknown,
                            subject: String(localized: "The exam schedule is not currently supported"),
                            auditory: String(localized: "I had to temporarily remove this feature because there is no time to move to a new API")
                        ),
                        PairViewModel(
                            from: "🤲", to: " ",
                            form: .unknown,
                            subject: String(localized: "But you can help me"),
                            auditory: "https://github.com/asiliuk/BsuirScheduleApp"
                        ),
                    ]
                )
            ]
        }
    }
}

// TODO: Support exams once again
//private extension DaySchedule.Day {
//
//    var title: String {
//        switch self {
//        case let .date(date): return Self.formatter.string(from: date)
//        case let .relative(weekDay): return weekDay.rawValue
//        }
//    }
//
//    static let formatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.locale = .by
//        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
//        return formatter
//    }()
//}
