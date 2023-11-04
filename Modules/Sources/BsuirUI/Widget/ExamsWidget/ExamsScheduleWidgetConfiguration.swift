import Foundation
import ScheduleCore

public struct ExamsScheduleWidgetConfiguration {
    public struct ExamDay: Equatable {
        public var date: Date
        public var pairs: [PairViewModel]
    }

    public enum Content {
        case exams(days: [ExamDay] = [])
        case noPinned
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
    public static let preview = Self(title: "000001", content: .previewExams)

    public static func noPinned(deeplink: URL? = nil) -> Self {
        Self(deeplink: deeplink, title: "---", content: .noPinned)
    }
}

// MARK: - Preview

private extension ExamsScheduleWidgetConfiguration.Content {
    static let previewExams = Self.exams(days: [
        ExamsScheduleWidgetConfiguration.ExamDay(
            date: .now,
            pairs: [
                PairViewModel(
                    from: "10:00",
                    to: "11:00",
                    interval: "10:00-11:00",
                    form: .exam,
                    subject: "Экзамен",
                    subjectFullName: "Экзамен",
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
                    subject: "Экзамен 2",
                    subjectFullName: "Экзамен 2",
                    auditory: "102-2"
                ),
                PairViewModel(
                    from: "13:15",
                    to: "14:30",
                    interval: "13:15-14:30",
                    form: .exam,
                    subject: "Экзамен 3",
                    subjectFullName: "Экзамен 3",
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
                    form: .exam,
                    subject: "Экзамен 4",
                    subjectFullName: "Экзамен 4",
                    auditory: "104-4"
                ),
            ]
        ),
    ])
}
