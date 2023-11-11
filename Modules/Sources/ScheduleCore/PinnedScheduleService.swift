import Foundation
import Dependencies
import Combine
import BsuirCore

public struct PinnedScheduleService {
    public var currentSchedule: @Sendable () -> ScheduleSource?
    public var setCurrentSchedule: @Sendable (ScheduleSource?) -> Void
    public var schedule: @Sendable () -> AnyPublisher<ScheduleSource?, Never>
}

// MARK: - Dependency

extension DependencyValues {
    public var pinnedScheduleService: PinnedScheduleService {
        get { self[PinnedScheduleService.self] }
        set { self[PinnedScheduleService.self] = newValue }
    }
}

extension PinnedScheduleService: DependencyKey {
    public static let liveValue: PinnedScheduleService = {
        @Dependency(\.widgetService) var widgetService
        return .live(storage: .asiliukShared, widgetService: widgetService)
    }()

    public static let previewValue: PinnedScheduleService = .constant(.group(name: "151004"))
}

// MARK: - Live

extension PinnedScheduleService {
    static func live(storage: UserDefaults, widgetService: WidgetService) -> Self {
        let pinnedScheduleStorage = storage
            .persistedDictionary(forKey: "pinned-schedule")
            .codable(ScheduleSource.self)
            .withPublisher()
        return Self(
            currentSchedule: {
                pinnedScheduleStorage.persisted.value
            },
            setCurrentSchedule: { newValue in
                pinnedScheduleStorage.persisted.value = newValue
                // Make sure widget UI is also updated
                widgetService.reloadAllPinned()
            },
            schedule: {
                pinnedScheduleStorage.publisher
            }
        )
    }

    static func constant(_ source: ScheduleSource) -> Self {
        Self(
            currentSchedule: { source },
            setCurrentSchedule: { _ in },
            schedule: { Just(source).eraseToAnyPublisher() }
        )
    }
}
