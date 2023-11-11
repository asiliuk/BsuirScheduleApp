import Foundation
import Dependencies
import WidgetKit

public struct WidgetService {
    public enum Timeline: String {
        case pinnedSchedule = "PinnedScheduleWidget"
        case examsSchedule = "ExamsScheduleWidget"
        case onlyExamsSchedule = "OnlyExamsScheduleWidget"
    }

    public let reload: (Timeline) -> Void
}

extension WidgetService {
    public func reloadAllPinned() {
        reload(.pinnedSchedule)
        reload(.examsSchedule)
        reload(.examsSchedule)
    }
}

extension WidgetService {
    public static let noop = WidgetService { _ in }
}

// MARK: - Dependency

extension DependencyValues {
    public var widgetService: WidgetService {
        get { self[WidgetServiceKey.self] }
        set { self[WidgetServiceKey.self] = newValue }
    }
}

private enum WidgetServiceKey: DependencyKey {
    static let liveValue = WidgetService(
        reload: { timeline in
            WidgetCenter.shared.reloadTimelines(ofKind: timeline.rawValue)
        }
    )

    static let previewValue = WidgetService.noop
    static let testValue = WidgetService.noop
}
