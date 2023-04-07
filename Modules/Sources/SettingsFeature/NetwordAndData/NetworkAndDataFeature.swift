import Foundation
import ReachabilityFeature
import ComposableArchitecture

public struct NetworkAndDataFeature: Reducer {
    public struct State: Equatable {
        @PresentationState var cacheClearedAlert: AlertState<Action.AlertAction>?
        var iisReachability = ReachabilityFeature.State(host: URL.iisApi.host()!)
        var appleReachability = ReachabilityFeature.State(host: "apple.com")
    }

    public enum Action: Equatable {
        public typealias AlertAction = Never
        case iisReachability(ReachabilityFeature.Action)
        case appleReachability(ReachabilityFeature.Action)
        case clearCacheTapped
        case alert(PresentationAction<AlertAction>)
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

            case .iisReachability, .appleReachability, .alert:
                return .none
            }
        }
        .ifLet(\.$cacheClearedAlert, action: /Action.alert)

        Scope(state: \.iisReachability, action: /Action.iisReachability) {
            ReachabilityFeature()
        }

        Scope(state: \.appleReachability, action: /Action.appleReachability) {
            ReachabilityFeature()
        }
    }
}
