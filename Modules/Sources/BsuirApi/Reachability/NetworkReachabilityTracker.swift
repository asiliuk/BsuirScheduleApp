import Foundation
import Dependencies

public struct NetworkReachabilityTracker {
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
        track: NetworkReachability.live
    )
}
