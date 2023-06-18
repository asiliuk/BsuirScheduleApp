import WidgetKit
import BsuirCore
import BsuirUI
import ScheduleCore
import Foundation
import Deeplinking

struct ScheduleEntry: TimelineEntry {
    var date = Date()
    var relevance: TimelineEntryRelevance? = nil
    var config: ScheduleWidgetConfiguration
}

extension ScheduleEntry {
    static let placeholder = ScheduleEntry(config: .placeholder)
    static let needsConfiguration = ScheduleEntry(config: .needsConfiguration)
    static let noPinned = ScheduleEntry(config: .noPinned)
    static let preview = ScheduleEntry(config: .preview)
}