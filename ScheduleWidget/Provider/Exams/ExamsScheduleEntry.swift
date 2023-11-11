import WidgetKit
import BsuirCore
import BsuirUI
import ScheduleCore
import Foundation
import Deeplinking

struct ExamsScheduleEntry: TimelineEntry {
    var date = Date()
    var relevance: TimelineEntryRelevance? = nil
    var config: ExamsScheduleWidgetConfiguration
}

extension ExamsScheduleEntry {
    static let placeholder = ExamsScheduleEntry(config: .placeholder)
    static let noPinned = ExamsScheduleEntry(config: .noPinned(deeplink: deeplinkRouter.url(for: .groups)))
    static let premiumLocked = ExamsScheduleEntry(config: .noPinned(deeplink: deeplinkRouter.url(for: .pinned())))
    static func preview(onlyExams: Bool) -> Self { ExamsScheduleEntry(config: .preview(onlyExams: onlyExams)) }
    
    static func noScheduleForPinned(title: String, subgroup: Int?) -> ExamsScheduleEntry {
        ExamsScheduleEntry(
            config: .noSchedule(
                deeplink: deeplinkRouter.url(for: .pinned(displayType: .exams)),
                title: title,
                subgroup: subgroup
            )
        )
    }
}
