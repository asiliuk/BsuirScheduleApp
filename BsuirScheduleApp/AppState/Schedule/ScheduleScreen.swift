import BsuirApi
import Combine
import Foundation
import os.log
import BsuirUI

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
        let compact: [Day]
        let exams: [Day]

        init(schedule: [DaySchedule], exams: [DaySchedule]) {
            self.continuous = ContinuousSchedule(schedule: schedule)
            self.compact = schedule.map(Day.init)
            self.exams = exams.map(Day.init)
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

struct Day {

    struct Pair {

        enum Form {
            case lecture
            case practice
            case lab
            case exam
            case unknown
        }

        let from: String
        let to: String
        let form: Form
        let subject: String
        let auditory: String
        let note: String?
        let weeks: String?
        let subgroup: String?
        let progress: PairProgress

        init(_ pair: BsuirApi.Pair, showWeeks: Bool = true, progress: PairProgress = .init(constant: 0)) {
            self.from = Self.timeFormatter.string(from: pair.startLessonTime.components) ?? "N/A"
            self.to = Self.timeFormatter.string(from: pair.endLessonTime.components) ?? "N/A"
            self.form = Form(pair.lessonType)
            self.subject = pair.subject
            self.auditory = pair.auditory.joined(separator: ", ")
            self.note = pair.note
            self.weeks = showWeeks ? pair.weekNumber.prettyName.capitalized : nil
            self.subgroup = pair.numSubgroup == 0 ? nil : "\(pair.numSubgroup)"
            self.progress = progress
        }

        private static let timeFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()
    }

    var title: String
    var subtitle: String?
    var pairs: [Pair]
    var isToday: Bool = false
    var isMostRelevant: Bool = false
}

extension Day {
    init(day: DaySchedule) {
        self.init(
            title: day.weekDay.title,
            pairs: day.schedule.map { Pair($0) }
        )
    }
}

private extension Day.Pair.Form {

    init(_ form: BsuirApi.Pair.Form?) {
        switch form {
        case .lecture: self = .lecture
        case .practice: self = .practice
        case .lab: self = .lab
        case .exam: self = .exam
        case nil: self = .unknown
        }
    }
}

private extension BsuirApi.Pair.Time {

    var components: DateComponents {
        DateComponents(timeZone: timeZone, hour: hour, minute: minute)
    }
}

private extension BsuirApi.WeekNum {

    var prettyName: String {
        switch self {
        case []: return "-"
        case .always: return "♾"
        case let numbers: return numbers.name
        }
    }

    private var name: String {
        var result: [String] = []
        if contains(.first) { result.append("1") }
        if contains(.second) { result.append("2") }
        if contains(.third) { result.append("3") }
        if contains(.forth) { result.append("4") }
        return result.joined(separator: ",")
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
