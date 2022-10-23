import Foundation
import Dependencies

extension DependencyValues {
    public var urlCache: URLCache {
        get { self[URLCacheKey.self] }
        set { self[URLCacheKey.self] = newValue }
    }
}

private enum URLCacheKey: DependencyKey {
    static let liveValue = URLCache()
}
