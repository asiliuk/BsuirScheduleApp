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
}

// MARK: - Favorites + Schedule Source

extension FavoritesService {
    public func addToFavorites(source: ScheduleSource) {
        switch source {
        case .group(let name):
            currentGroupNames.append(name)
        case .lector(let lector):
            currentLectorIds.append(lector.id)
        }
    }

    public func removeFromFavorites(source: ScheduleSource) {
        switch source {
        case .group(let name):
            currentGroupNames.remove(name)
        case .lector(let lector):
            currentLectorIds.remove(lector.id)
        }
    }
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
        @Dependency(\.cloudSyncService) var cloudSyncService
        @Dependency(\.defaultAppStorage) var storage
        return LiveFavoritesService(
            storage: storage,
            legacyStorage: .standard,
            widgetService: widgetService,
            cloudSyncService: cloudSyncService
        )
    }()

    static let previewValue: any FavoritesService = FavoriteServiceMock(
        groupNames: ["251003", "251004"],
        lecturerIds: [504394, 500570],
        freeLoveHighScore: 69
    )
}
