import Foundation
import SystemConfiguration
import Combine

final class NetworkReachabilityManager {
    private let reachabilityQueue = DispatchQueue(label: "com.asiliuk.BsuirScheduleApp.NetworkReachabilityManager")
    private let reachability: SCNetworkReachability

    init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }
        self.reachability = reachability
    }

    deinit {
        stopListening()
    }

    func startListening(onQueue queue: DispatchQueue = .main) -> AnyPublisher<NetworkReachabilityStatus, Never>? {
        stopListening()

        var flags = SCNetworkReachabilityFlags()
        let couldGetFlags = SCNetworkReachabilityGetFlags(reachability, &flags)

        let flagsSubject = CurrentValueSubject<SCNetworkReachabilityFlags?, Never>(couldGetFlags ? flags : nil)

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: Unmanaged.passUnretained(flagsSubject).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: SCNetworkReachabilityCallBack = { _, flags, info in
            guard let info = info else { return }

            let instance = Unmanaged<CurrentValueSubject<SCNetworkReachabilityFlags?, Never>>.fromOpaque(info).takeUnretainedValue()
            instance.value = flags
        }

        guard
            SCNetworkReachabilitySetDispatchQueue(reachability, reachabilityQueue),
            SCNetworkReachabilitySetCallback(reachability, callback, &context)
        else { return nil }

        return flagsSubject
            .compactMap { $0 }
            .map(NetworkReachabilityStatus.init)
            .removeDuplicates()
            .handleEvents(
                receiveCompletion: { [weak self] _ in self?.stopListening() },
                receiveCancel: { [weak self] in self?.stopListening() }
            )
            .eraseToAnyPublisher()
    }

    func stopListening() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }
}
