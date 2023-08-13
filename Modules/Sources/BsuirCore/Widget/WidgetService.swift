import Foundation
import Dependencies
import WidgetKit

public struct WidgetService {
    public enum Timeline: String {
        case pinnedSchedule = "PinnedScheduleWidget"
    }

    public let reload: (Timeline) -> Void
}

// MARK: - Dependecy

extension DependencyValues {
    public var widgetService: WidgetService {
        get { self[WidgetService.self] }
        set { self[WidgetService.self] = newValue }
    }
}

extension WidgetService: DependencyKey {
    public static let liveValue = WidgetService(
        reload: { timeline in
            WidgetCenter.shared.reloadTimelines(ofKind: timeline.rawValue)
        }
    )

    public static let previewValue = WidgetService(reload: { _ in })
    public static let testValue: WidgetService = WidgetService(reload: { _ in })
}
