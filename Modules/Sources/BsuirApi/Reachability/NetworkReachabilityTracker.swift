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
    #if canImport(SystemConfiguration)
    static let liveValue = NetworkReachabilityTracker(
        track: NetworkReachability.live
    )
    #else
    static let liveValue = NetworkReachabilityTracker { _ in .empty() }
    #endif
}
