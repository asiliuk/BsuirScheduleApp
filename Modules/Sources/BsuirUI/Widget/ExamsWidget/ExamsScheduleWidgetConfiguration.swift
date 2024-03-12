import Foundation
import ScheduleCore

public struct ExamsScheduleWidgetConfiguration {
    public struct ExamDay: Equatable {
        public var date: Date
        public var pairs: [PairViewModel]

        public init(date: Date, pairs: [PairViewModel]) {
            self.date = date
            self.pairs = pairs
        }
    }

    public enum Content {
        case exams(days: [ExamDay] = [])
        case noSchedule
        case noPinned
        case failed(refresh: Date)
    }

    public var deeplink: URL? = nil
    public var title: String
    public var subgroup: Int?
    public var content: Content

    public init(
        deeplink: URL? = nil,
        title: String,
        subgroup: Int? = nil,
        content: Content
    ) {
        self.deeplink = deeplink
        self.title = title
        self.subgroup = subgroup
        self.content = content
    }
}

extension ExamsScheduleWidgetConfiguration {
    public static let placeholder = Self(title: "---", content: .exams())
    public static func preview(onlyExams: Bool) -> Self {
        Self(title: "000001", content:  onlyExams ? .previewOnlyExams : .previewExams)
    }

    public static func noPinned(deeplink: URL? = nil) -> Self {
        Self(deeplink: deeplink, title: "---", content: .noPinned)
    }

    public static func noSchedule(deeplink: URL? = nil, title: String, subgroup: Int?) -> Self {
        Self(deeplink: deeplink, title: title, subgroup: subgroup, content: .noSchedule)
    }

    public static func failed(deeplink: URL? = nil, title: String, subgroup: Int?, refresh: Date) -> Self {
        Self(deeplink: deeplink, title: title, subgroup: subgroup, content: .failed(refresh: refresh))
    }
}

// MARK: - Preview

private extension ExamsScheduleWidgetConfiguration.Content {
    static let previewOnlyExams: Self = {
        guard case var .exams(days) = previewExams else {
            assertionFailure()
            return .noSchedule
        }

        return .exams(days: days.map { day in
            var copy = day
            copy.pairs = copy.pairs.filter { $0.form == .exam }
            return copy
        })
    }()

    static let previewExams = Self.exams(days: [
        ExamsScheduleWidgetConfiguration.ExamDay(
            date: .now,
            pairs: [
                PairViewModel(
                    from: "10:00",
                    to: "11:00",
                    interval: "10:00-11:00",
                    form: .consultation,
                    subject: "Консультация",
                    subjectFullName: "Консультация",
                    auditory: "101-1",
                    progress: .init(constant: 0.5)
                ),
            ]
        ),
        ExamsScheduleWidgetConfiguration.ExamDay(
            date: .now.addingTimeInterval(3600 * 24),
            pairs: [
                PairViewModel(
                    from: "12:00",
                    to: "13:00",
                    interval: "12:00-13:00",
                    form: .exam,
                    subject: "Экзамен",
                    subjectFullName: "Экзамен",
                    auditory: "102-2"
                ),
                PairViewModel(
                    from: "13:15",
                    to: "14:30",
                    interval: "13:15-14:30",
                    form: .lecture,
                    subject: "Лекция",
                    subjectFullName: "Лекция",
                    auditory: "103-2"
                ),
            ]
        ),
        ExamsScheduleWidgetConfiguration.ExamDay(
            date: .now.addingTimeInterval(3600 * 24 * 2),
            pairs: [
                PairViewModel(
                    from: "10:00",
                    to: "11:00",
                    interval: "10:00-11:00",
                    form: .practice,
                    subject: "Практика",
                    subjectFullName: "Прктика",
                    auditory: "104-4"
                ),
            ]
        ),
        ExamsScheduleWidgetConfiguration.ExamDay(
            date: .now.addingTimeInterval(3600 * 24 * 3),
            pairs: [
                PairViewModel(
                    from: "10:00",
                    to: "11:00",
                    interval: "10:00-11:00",
                    form: .consultation,
                    subject: "Консультация 2",
                    subjectFullName: "Консультация 2",
                    auditory: "105-5"
                ),
                PairViewModel(
                    from: "12:00",
                    to: "13:00",
                    interval: "12:00-13:00",
                    form: .exam,
                    subject: "Экзамен 2",
                    subjectFullName: "Экзамен 2",
                    auditory: "105-6"
                ),
            ]
        ),
    ])
}

private extension ExamsScheduleWidgetConfiguration.Content {
    var examsDays: [ExamsScheduleWidgetConfiguration.ExamDay]? {
        guard case .exams(let days) = self else {
            return nil
        }
        return days
    }
}
