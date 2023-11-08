import Foundation
import ScheduleCore

public struct PinnedScheduleWidgetConfiguration {
    public enum Content {
        case pairs(passed: [PairViewModel] = [], upcoming: [PairViewModel] = [])
        case needsConfiguration
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

extension PinnedScheduleWidgetConfiguration {
    public static let placeholder = Self(title: "---", content: .pairs())
    public static let needsConfiguration = Self(title: "---", content: .needsConfiguration)
    public static let preview = Self(title: "000001", content: .previewPairs)

    public static func noPinned(deeplink: URL? = nil) -> Self {
        Self(deeplink: deeplink, title: "---", content: .noPinned)
    }

    public static func empty(title: String, deeplink: URL? = nil) -> Self {
        Self(deeplink: deeplink, title: title, content: .pairs(passed: [], upcoming: []))
    }
}

// MARK: - Preview

private extension PinnedScheduleWidgetConfiguration.Content {
    static let previewPairs = Self.pairs(
        passed: [
            PairViewModel(
                from: "10:00",
                to: "11:00",
                interval: "10:00-11:00",
                form: .lab,
                subject: "Лаба",
                subjectFullName: "Лаба",
                auditory: "101-1",
                progress: .init(constant: 1)
            ),
        ],
        upcoming: [
            PairViewModel(
                from: "11:00",
                to: "12:00",
                interval: "11:00-12:00",
                form: .lecture,
                subject: "Лекция",
                subjectFullName: "Лекция",
                auditory: "102-2"
            ),
            PairViewModel(
                from: "12:00",
                to: "13:00",
                interval: "12:00-13:00",
                form: .practice,
                subject: "ПЗ",
                subjectFullName: "ПЗ",
                auditory: "103-3"
            ),
            PairViewModel(
                from: "13:00",
                to: "14:00",
                interval: "13:00-14:00",
                form: .lab,
                subject: "Другая Лаба",
                subjectFullName: "Другая Лаба",
                auditory: "104-4",
                subgroup: 2
            ),
            PairViewModel(
                from: "13:00",
                to: "14:00",
                interval: "13:00-14:00",
                form: .practice,
                subject: "Другое ПЗ",
                subjectFullName: "Другое ПЗ",
                auditory: "105-5",
                subgroup: 1
            )
        ]
    )
}
