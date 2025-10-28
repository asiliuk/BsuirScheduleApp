import Combine
import Dependencies
import Foundation
import Sharing

public protocol PairFormDisplayService {
    func start()
}

// MARK: - Live

final class LivePairFormDisplayService: PairFormDisplayService {
    @Dependency(\.widgetService) var widgetService
    @Dependency(\.defaultAppStorage) var defaultAppStorage
    @SharedReader(.alwaysShowFormIcon) var alwaysShowFormIcon

    private var reloadingCancellable: AnyCancellable?

    func start() {
        migrateKeysIfNeeded()
        monitorWidgetReloading()
    }

    private func migrateKeysIfNeeded() {
        for pairForm in PairViewForm.allCases {
            guard let value = defaultAppStorage.string(forKey: pairForm.legacyDefaultsKey) else { continue }
            defaultAppStorage.set(nil, forKey: pairForm.legacyDefaultsKey)
            defaultAppStorage.set(value, forKey: pairForm.colorDefaultsKey)
        }
    }

    private func monitorWidgetReloading() {
        reloadingCancellable = Publishers
            .MergeMany(
                PairViewForm
                    .allCases
                    .map { SharedReader(.pairFormColor(for: $0)).publisher }
            )
            .map { _ in Void() }
            .merge(with: $alwaysShowFormIcon.publisher.map { _ in Void() })
            .receive(on: RunLoop.main)
            .sink { [widgetService] _ in widgetService.reloadAll() }
    }
}

// MARK: - Noop

final class NoopPairFormDisplayService: PairFormDisplayService {
    func start() {}
}

// MARK: - Dependency

private enum PairFormDisplayServiceKey: DependencyKey {
  static let liveValue: any PairFormDisplayService = LivePairFormDisplayService()
  static let previewValue: any PairFormDisplayService = NoopPairFormDisplayService()
  static let testValue: any PairFormDisplayService = NoopPairFormDisplayService()
}

extension DependencyValues {
    public var pairFormDisplayService: any PairFormDisplayService {
        get { self[PairFormDisplayServiceKey.self] }
        set { self[PairFormDisplayServiceKey.self] = newValue }
    }
}
