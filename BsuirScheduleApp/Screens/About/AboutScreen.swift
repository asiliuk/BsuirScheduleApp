import Foundation
import Kingfisher

final class AboutScreen: ObservableObject {
    @Published var isCacheCleared = false

    init(urlCache: URLCache?, imageCache: ImageCache) {
        self.urlCache = urlCache
        self.imageCache = imageCache
    }

    func clearCache() {
        urlCache?.removeAllCachedResponses()
        imageCache.clearCache()
        isCacheCleared = true
    }

    private let imageCache: ImageCache
    private let urlCache: URLCache?
}
