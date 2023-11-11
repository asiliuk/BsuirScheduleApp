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
    public let reloadAll: () -> Void
}

extension WidgetService {
    public static let noop = WidgetService(reload: { _ in }, reloadAll: {})
}

// MARK: - Dependency

extension DependencyValues {
    public var widgetService: WidgetService {
        get { self[WidgetServiceKey.self] }
        set { self[WidgetServiceKey.self] = newValue }
    }
}

private enum WidgetServiceKey: DependencyKey {
    static let liveValue: WidgetService = {
        let widgetCenter = WidgetCenter.shared
        return WidgetService(
            reload: { widgetCenter.reloadTimelines(ofKind: $0.rawValue) },
            reloadAll: { widgetCenter.reloadAllTimelines() }
        )
    }()

    static let previewValue = WidgetService.noop
    static let testValue = WidgetService.noop
}
