import Foundation
import Dependencies
import Combine
import BsuirCore
import CasePaths

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
        @Dependency(\.cloudSyncService) var cloudSyncService
        @Dependency(\.defaultAppStorage) var storage
        return .live(storage: storage, widgetService: widgetService, cloudSyncService: cloudSyncService)
    }()

    public static let previewValue: PinnedScheduleService = .constant(.group(name: "151004"))
}

// MARK: - Live

extension PinnedScheduleService {
    static func live(
        storage: UserDefaults,
        widgetService: WidgetService,
        cloudSyncService: CloudSyncService
    ) -> Self {
        let pinnedScheduleStorage = storage
            .persistedDictionary(forKey: "pinned-schedule")
            .sync(with: cloudSyncService, forKey: "cloud-pinned-schedule", shouldSyncInitialLocalValue: true)
            .codable(CloudSyncableScheduleSource.self)
            .unwrap(withDefault: .nothing)
            .withPublisher()

        return Self(
            currentSchedule: {
                pinnedScheduleStorage.persisted.value[case: \.source]
            },
            setCurrentSchedule: { newValue in
                pinnedScheduleStorage.persisted.value = CloudSyncableScheduleSource(source: newValue)
                // Make sure widget UI is also updated
                widgetService.reloadAll()
            },
            schedule: {
                pinnedScheduleStorage.publisher.map(\.[case: \.source]).eraseToAnyPublisher()
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

// MARK: - CloudScheduleSource

/// Wrapper around schedule source intended to be synced with the cloud
///
/// iCloud is not handling changing from `pinned` -> `nil` -> `another pinned` very well
/// at some point it sends notification that pinned was removed even if new non-nil value was set after
/// to prevent such situation I prefer to always store `something` even if it is garbage dictionary, it seems to work well
@CasePathable
public enum CloudSyncableScheduleSource: Equatable, Codable {
    case source(ScheduleSource)
    case nothing

    init(source: ScheduleSource?) {
        if let source {
            self = .source(source)
        } else {
            self = .nothing
        }
    }

    public var source: ScheduleSource? {
        guard case .source(let source) = self else {
            return nil
        }
        return source
    }

    public init(from decoder: any Decoder) throws {
        do {
            self = .source(try ScheduleSource(from: decoder))
        } catch {
            self = .nothing
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .source(let source):
            try source.encode(to: encoder)
        case .nothing:
            var container = encoder.singleValueContainer()
            let placeholder: [String: String] = ["nothing": "nothing to see here"]
            try container.encode(placeholder)
        }
    }
}
