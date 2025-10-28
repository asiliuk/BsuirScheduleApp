import Combine
import Dependencies
import Foundation
import Sharing

public protocol WidgetReloadingService {
    func start()
}

// MARK: - Live

final class LiveWidgetReloadingService: WidgetReloadingService {
    @Dependency(\.widgetService) var widgetService
    @Shared(.alwaysShowFormIcon) var alwaysShowFormIcon

    private var reloadingCancellable: AnyCancellable?

    func start() {
        reloadingCancellable = $alwaysShowFormIcon.publisher
            .receive(on: RunLoop.main)
            .sink { [widgetService] _ in widgetService.reloadAll() }
    }
}

// MARK: - Noop

final class NoopWidgetReloadingService: WidgetReloadingService {
    func start() {}
}

// MARK: - Dependency

private enum WidgetReloadingServiceKey: DependencyKey {
  static let liveValue: any WidgetReloadingService = LiveWidgetReloadingService()
  static let previewValue: any WidgetReloadingService = NoopWidgetReloadingService()
  static let testValue: any WidgetReloadingService = NoopWidgetReloadingService()
}

extension DependencyValues {
    public var widgetReloadingService: any WidgetReloadingService {
        get { self[WidgetReloadingServiceKey.self] }
        set { self[WidgetReloadingServiceKey.self] = newValue }
    }
}
