import Foundation
import Dependencies

extension DependencyValues {
    public var favorites: FavoritesContainerProtocol {
        get { self[FavoritesContainerKey.self] }
        set { self[FavoritesContainerKey.self] = newValue }
    }
}

private enum FavoritesContainerKey: DependencyKey {
    static let liveValue: FavoritesContainerProtocol = FavoritesContainer(storage: .standard)
}
