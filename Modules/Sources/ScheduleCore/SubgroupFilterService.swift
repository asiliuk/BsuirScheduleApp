import Foundation
import Dependencies
import BsuirCore

extension DependencyValues {
    public var subgroupFilterService: SubgroupFilterService {
        get { self[SubgroupFilterServiceKey.self] }
        set { self[SubgroupFilterServiceKey.self] = newValue }
    }
}

public struct SubgroupFilterService {
    public var preferredSubgroup: @Sendable (_ source: ScheduleSource) -> PersistedValue<Int?>
}

private enum SubgroupFilterServiceKey: DependencyKey {
    static let liveValue: SubgroupFilterService = {
        @Dependency(\.widgetService) var widgetService
        @Dependency(\.pinnedScheduleService) var pinnedScheduleService
        @Dependency(\.defaultAppStorage) var storage
        return .live(
            widgetService: widgetService,
            pinnedScheduleService: pinnedScheduleService,
            storage: UncheckedSendable(storage)
        )
    }()
    
    static let previewValue = SubgroupFilterService(preferredSubgroup: { _ in .constant(1) })
}

// MARK: - Live

private extension SubgroupFilterService {
    static func live(
        widgetService: WidgetService,
        pinnedScheduleService: PinnedScheduleService,
        storage: UncheckedSendable<UserDefaults>
    ) -> Self {
        return SubgroupFilterService { [storage] source in
            return storage.wrappedValue
                .persistedInteger(forKey: source.preferredSubgroupKey)
                // Transform 0 subgroup to nil
                .map(fromValue: { $0 == 0 ? nil : $0 }, toValue: { $0 ?? 0 })
                .onDidSet {
                    guard pinnedScheduleService.currentSchedule() == source else { return }
                    widgetService.reloadAll()
                }
        }
    }
}

private extension ScheduleSource {
    var preferredSubgroupKey: String {
        switch self {
        case .group(let name): "group-\(name)-preferred-subgroup"
        case .lector(let employee): "lector-\(employee.id)-preferred-subgroup"
        }
    }
}
