import Foundation
import URLRouting

extension URLRoutingClient {
    static func liveCaching<BaseRoute, R: ParserPrinter>(
        in cache: URLCache,
        router: R,
        session: URLSession = .shared,
        decoder: JSONDecoder = .init()
    ) -> URLRoutingClient<CachingRoute<BaseRoute>> where R.Input == URLRequestData, R.Output == BaseRoute {
        let liveClient = URLRoutingClient<BaseRoute>.live(router: router, session: session, decoder: decoder)
        return .init(
            request: { route in
                let request = try router.request(for: route.base)

                // Check cache if needed
                if !route.ignoreCache, let cached = cache.cachedResponse(for: request) {
                    return (cached.data, cached.response)
                }

                // Make real call if no cache or it was ignored
                let (data, response) = try await liveClient.data(for: route.base)
                cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                return (data, response)
            },
            decoder: decoder
        )
    }
}

struct CachingRoute<Route> {
    var ignoreCache: Bool
    var base: Route
}
