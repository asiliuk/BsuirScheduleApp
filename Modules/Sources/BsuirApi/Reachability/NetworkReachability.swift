import Foundation
import Combine

public struct NetworkReachability {
    public let status: () -> AnyPublisher<NetworkReachabilityStatus, Never>
}

extension NetworkReachability {
    public static func live(host: String) -> Self {
        let reachabilityManager = NetworkReachabilityManager(host: host)
        return .init { reachabilityManager!.startListening()! }
    }
}
