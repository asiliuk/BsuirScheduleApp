import Foundation
import BsuirApi
import ComposableArchitecture

public struct ReachabilityFeature: ReducerProtocol {
    public struct State: Equatable {
        public var status: NetworkReachabilityStatus
        public var host: String

        public init(host: String) {
            self.host = host
            self.status = .unknown
        }
    }

    public enum Action: Equatable {
        case task
        case setStatus(NetworkReachabilityStatus)
    }

    @Dependency(\.networkReachabilityTracker) var networkReachabilityTracker

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            let tracker = networkReachabilityTracker.track(state.host)
            return .run { send in
                for try await status in tracker.status().values {
                    await send(.setStatus(status))
                }
            }

        case let .setStatus(value):
            state.status = value
            return .none
        }
    }
}
