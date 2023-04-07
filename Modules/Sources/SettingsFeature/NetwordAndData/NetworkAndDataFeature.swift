import Foundation
import ReachabilityFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct NetworkAndDataFeature: Reducer {
    public struct State: Equatable {
        // TODO: new navigation logic
        var cacheClearedAlert: AlertState<Action>?
        var iisReachability = ReachabilityFeature.State(host: URL.iisApi.host()!)
        var appleReachability = ReachabilityFeature.State(host: "apple.com")
    }

    public enum Action: Equatable {
        case iisReachability(ReachabilityFeature.Action)
        case appleReachability(ReachabilityFeature.Action)

        case clearCacheTapped
        case cacheClearedAlertDismissed
    }

    @Dependency(\.apiClient.clearCache) var clearNetworkCache
    @Dependency(\.imageCache) var imageCache

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clearCacheTapped:
                state.cacheClearedAlert = AlertState(
                    title: TextState("alert.clearCache.title"),
                    message: TextState("alert.clearCache.message")
                )
                return .fireAndForget {
                    await clearNetworkCache()
                    imageCache.clearCache()
                }

            case .cacheClearedAlertDismissed:
                state.cacheClearedAlert = nil
                return .none

            case .iisReachability, .appleReachability:
                return .none
            }
        }

        Scope(state: \.iisReachability, action: /Action.iisReachability) {
            ReachabilityFeature()
        }

        Scope(state: \.appleReachability, action: /Action.appleReachability) {
            ReachabilityFeature()
        }
    }
}
