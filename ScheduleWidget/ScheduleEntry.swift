import WidgetKit
import BsuirCore
import Foundation

struct ScheduleEntry: TimelineEntry {
    enum Content {
        case pairs(passed: [PairViewModel] = [], upcoming: [PairViewModel] = [])
        case needsConfiguration
    }

    enum Identifier {
        case group(Int)
        case lecturer(Int)
    }

    var date = Date()
    var relevance: TimelineEntryRelevance? = nil
    var id: Identifier?
    var title: String
    var content: Content
}

extension ScheduleEntry {
    static let placeholder = Self(id: nil, title: "---", content: .pairs())
    static let needsConfiguration = Self(id: nil, title: "---", content: .needsConfiguration)
    static let preview = Self(id: nil, title: "000001", content: .previewPairs)
}

private extension ScheduleEntry.Content {
    static let previewPairs = Self.pairs(
        passed: [
            PairViewModel(
                from: "10:00",
                to: "11:00",
                form: .lab,
                subject: "Лаба",
                auditory: "101-1",
                progress: .init(constant: 1)
            ),
        ],
        upcoming: [
            PairViewModel(
                from: "11:00",
                to: "12:00",
                form: .lecture,
                subject: "Лекция",
                auditory: "102-2"
            ),
            PairViewModel(
                from: "12:00",
                to: "13:00",
                form: .practice,
                subject: "ПЗ",
                auditory: "103-3"
            ),
            PairViewModel(
                from: "13:00",
                to: "14:00",
                form: .lab,
                subject: "Другая Лаба",
                auditory: "104-4",
                subgroup: "2"
            ),
            PairViewModel(
                from: "13:00",
                to: "14:00",
                form: .practice,
                subject: "Другое ПЗ",
                auditory: "105-5",
                subgroup: "1"
            )
        ]
    )
}
