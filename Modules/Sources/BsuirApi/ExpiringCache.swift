import Foundation

final class ExpiringCache: URLCache {
    init(expiration: TimeInterval, memoryCapacity: Int, diskCapacity: Int, diskPath: String?) {
        self.expiration = expiration
        super.init(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: diskPath)
    }

    override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard let cache = super.cachedResponse(for: request) else { return nil }

        guard let expirationDate = cache.userInfo?[expirationKey] as? Date else {
            updateCachedResponse(cache, for: request)
            return cache
        }

        guard expirationDate.timeIntervalSinceNow > 0 else {
            removeCachedResponse(for: request)
            return nil
        }
        return cache
    }

    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        guard super.cachedResponse(for: request) == nil else { return }
        updateCachedResponse(cachedResponse, for: request)
    }

    private func updateCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        var userInfo = cachedResponse.userInfo ?? [:]
        userInfo[expirationKey] = Date(timeIntervalSinceNow: expiration)
        let cache = CachedURLResponse(
            response: cachedResponse.response,
            data: cachedResponse.data,
            userInfo: userInfo,
            storagePolicy: cachedResponse.storagePolicy
        )
        super.storeCachedResponse(cache, for: request)
    }

    private let expirationKey = "com.mylivn.request_eqxpiration"
    private let expiration: TimeInterval
}
