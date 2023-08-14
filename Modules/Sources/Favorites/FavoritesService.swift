import Foundation
import BsuirCore
import BsuirApi
import ScheduleCore
import Collections
import Combine
import Dependencies

public protocol FavoritesService: AnyObject {
    var currentGroupNames: OrderedSet<String> { get set }
    var groupNames: AnyPublisher<OrderedSet<String>, Never> { get }
    var currentLectorIds: OrderedSet<Int> { get set }
    var lecturerIds: AnyPublisher<OrderedSet<Int>, Never> { get }
    var currentPinnedSchedule: ScheduleSource? { get set }
    var pinnedSchedule: AnyPublisher<ScheduleSource?, Never> { get }
    var freeLoveHighScore: Int { get set }
}

// MARK: - Dependency

extension DependencyValues {
    public var favorites: FavoritesService {
        get { self[FavoritesServiceKey.self] }
        set { self[FavoritesServiceKey.self] = newValue }
    }
}

private enum FavoritesServiceKey: DependencyKey {
    static let liveValue: any FavoritesService = {
        @Dependency(\.widgetService) var widgetService
        return LiveFavoritesService(
            storage: .asiliukShared,
            legacyStorage: .standard,
            widgetService: widgetService
        )
    }()

    static let previewValue: any FavoritesService = FavoriteServiceMock(
        groupNames: ["151003", "151005"],
        lecturerIds: [504394, 500570],
        pinnedSchedule: .group(name: "151004"),
        freeLoveHighScore: 69
    )
}
