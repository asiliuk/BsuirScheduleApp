import Foundation
import Dependencies
import Kingfisher

extension DependencyValues {
    public var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}

private enum ImageCacheKey: DependencyKey {
    static let liveValue = ImageCache.default
}
