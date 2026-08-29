import WidgetKit
import AppIntents
import Foundation
import Dependencies

public struct ReloadTimelineIntent: AppIntent {
    public static var title: LocalizedStringResource = "Reload widget timeline"
    public static var isDiscoverable: Bool { false }
    public var timeline: WidgetTimeline?

    public init(timeline: WidgetTimeline?) {
        self.timeline = timeline
    }

    public init() {
        self.timeline = nil
    }

    public func perform() async throws -> some IntentResult {
        if let timeline {
            WidgetCenter.shared.reloadTimelines(ofKind: timeline.rawValue)
        } else {
            WidgetCenter.shared.reloadAllTimelines()
        }
        return .result()
    }

}
