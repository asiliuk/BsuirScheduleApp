import Foundation
import Dependencies

public struct NetworkReachabilityTracker {
    public var iisApi: NetworkReachability
    public var track: (String) -> NetworkReachability
}

extension DependencyValues {
    public var networkReachabilityTracker: NetworkReachabilityTracker {
        get { self[NetworkReachabilityTrackerKey.self] }
        set { self[NetworkReachabilityTrackerKey.self] = newValue }
    }
}

private enum NetworkReachabilityTrackerKey: DependencyKey {
    static let liveValue = NetworkReachabilityTracker(
        iisApi: .live(host: URL.iisApi.bsr_host),
        track: NetworkReachability.live
    )
}
