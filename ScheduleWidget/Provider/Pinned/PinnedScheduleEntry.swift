import WidgetKit
import BsuirCore
import BsuirUI
import ScheduleCore
import Foundation
import Deeplinking

struct PinnedScheduleEntry: TimelineEntry {
    var date = Date()
    var relevance: TimelineEntryRelevance? = nil
    var config: PinnedScheduleWidgetConfiguration
}

extension PinnedScheduleEntry {
    static let placeholder = PinnedScheduleEntry(config: .placeholder)
    static let noPinned = PinnedScheduleEntry(config: .noPinned(deeplink: deeplinkRouter.url(for: .groups)))
    static let premiumLocked = PinnedScheduleEntry(config: .noPinned(deeplink: deeplinkRouter.url(for: .pinned())))
    static let preview = PinnedScheduleEntry(config: .preview)

    static func emptyPinned(title: String) -> PinnedScheduleEntry {
        PinnedScheduleEntry(
            config: .empty(
                title: title,
                deeplink: deeplinkRouter.url(for: .pinned())
            )
        )
    }
}
