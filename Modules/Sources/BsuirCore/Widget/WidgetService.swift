import Foundation
import Dependencies
import WidgetKit

public struct WidgetService {
    public enum Timeline: String {
        case pinnedSchedule = "PinnedScheduleWidget"
    }

    public let reload: (Timeline) -> Void
}

extension WidgetService {
    public static let noop = WidgetService { _ in }
}

// MARK: - Dependecy

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
