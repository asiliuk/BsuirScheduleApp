/// Copy-pasted from [here](https://github.com/Alamofire/Alamofire/blob/a41c07a558b508bcf3a66552c726cab5dda65501/Source/NetworkReachabilityManager.swift)

import Foundation
import SystemConfiguration

/// Defines the various states of network reachability.
public enum NetworkReachabilityStatus: Equatable {
    /// It is unknown whether the network is reachable.
    case unknown
    /// The network is not reachable.
    case notReachable
    /// The network is reachable on the associated `ConnectionType`.
    case reachable(ConnectionType)

    init(_ flags: SCNetworkReachabilityFlags) {
        guard flags.isActuallyReachable else { self = .notReachable; return }
        var networkStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi)
        if flags.isCellular { networkStatus = .reachable(.cellular) }
        self = networkStatus
    }

    /// Defines the various connection types detected by reachability flags.
    public enum ConnectionType {
        /// The connection type is either over Ethernet or WiFi.
        case ethernetOrWiFi
        /// The connection type is a cellular connection.
        case cellular
    }
}

extension SCNetworkReachabilityFlags {
    var isReachable: Bool { contains(.reachable) }
    var isConnectionRequired: Bool { contains(.connectionRequired) }
    var canConnectAutomatically: Bool { contains(.connectionOnDemand) || contains(.connectionOnTraffic) }
    var canConnectWithoutUserInteraction: Bool { canConnectAutomatically && !contains(.interventionRequired) }
    var isActuallyReachable: Bool { isReachable && (!isConnectionRequired || canConnectWithoutUserInteraction) }
    var isCellular: Bool { contains(.isWWAN) }
}
