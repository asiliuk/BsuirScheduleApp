import Foundation
import Dependencies

extension DependencyValues {
    public var favorites: FavoritesContainer {
        get { self[FavoritesContainerKey.self] }
        set { self[FavoritesContainerKey.self] = newValue }
    }
}

private enum FavoritesContainerKey: DependencyKey {
    static let liveValue = FavoritesContainer(storage: .standard)
}
