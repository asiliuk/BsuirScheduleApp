import Foundation
import Dependencies
import URLRouting

extension DependencyValues {
    public var iisClient: URLRoutingClient<IISRoute> {
        get { self[BsuirIISRouteClientKey.self] }
        set { self[BsuirIISRouteClientKey.self] = newValue }
    }
}

private enum BsuirIISRouteClientKey: DependencyKey {
    static let liveValue = URLRoutingClient<IISRoute>.live(
        router: iisRouter,
        decoder: .bsuirDecoder
    )
}
