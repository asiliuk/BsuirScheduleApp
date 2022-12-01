import Foundation
import BsuirApi
import ComposableArchitecture

public struct ReachabilityFeature: ReducerProtocol {
    public struct State: Equatable {
        var status: NetworkReachabilityStatus
        var name: String

        public init(host: String) {
            self.name = host
            self.status = .unknown
        }
    }

    public enum Action: Equatable {
        case task
        case setStatus(NetworkReachabilityStatus)
    }

    private let networkReachability: NetworkReachability

    public init(_ networkReachability: NetworkReachability) {
        self.networkReachability = networkReachability
    }

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            return .run { send in
                for try await status in networkReachability.status().values {
                    await send(.setStatus(status))
                }
            }

        case let .setStatus(value):
            state.status = value
            return .none
        }
    }
}
