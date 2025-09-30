import Foundation
import Dependencies
import BsuirCore

public struct PinnedScheduleHashService {
    public var lastKnownHash: @Sendable (_ source: ScheduleSource) -> PersistedValue<String?>
}

// MARK: - Dependency

extension DependencyValues {
    public var pinnedScheduleHashService: PinnedScheduleHashService {
        get { self[PinnedScheduleHashService.self] }
        set { self[PinnedScheduleHashService.self] = newValue }
    }
}

extension PinnedScheduleHashService: DependencyKey {
    public static let liveValue: PinnedScheduleHashService = {
        @Dependency(\.widgetService) var widgetService
        @Dependency(\.pinnedScheduleService) var pinnedScheduleService
        @Dependency(\.defaultAppStorage) var storage
        return .live(
            widgetService: widgetService,
            pinnedScheduleService: pinnedScheduleService,
            storage: UncheckedSendable(storage)
        )
    }()
}

// MARK: - Live

extension PinnedScheduleHashService {
    static func live(
        widgetService: WidgetService,
        pinnedScheduleService: PinnedScheduleService,
        storage: UncheckedSendable<UserDefaults>
    ) -> Self {
        return Self { source in
            let scheduleHash = storage.wrappedValue.persistedString(forKey: source.scheduleHashKey)
            return PersistedValue(
                get: { scheduleHash.value },
                set: { newValue in
                    guard
                        source == pinnedScheduleService.currentSchedule(),
                        newValue != scheduleHash.value
                    else { return }

                    defer { scheduleHash.value = newValue }

                    // If not initial value
                    guard scheduleHash.value != nil else { return }

                    // Reload widgets to show new schedule
                    widgetService.reloadAll()
                }
            )
        }
    }
}

private extension ScheduleSource {
    var scheduleHashKey: String {
        switch self {
        case .group(let name): "group-\(name)-schedule-hash"
        case .lector(let employee): "lector-\(employee.id)-schedule-hash"
        }
    }
}
