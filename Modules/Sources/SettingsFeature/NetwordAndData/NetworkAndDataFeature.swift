import Foundation
import ReachabilityFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct NetworkAndDataFeature: Reducer {
    public struct State: Equatable {
        var cacheClearedAlert: AlertState<Action>?
        var iisReachability = ReachabilityFeature.State(host: URL.iisApi.host()!)
        var appleReachability = ReachabilityFeature.State(host: "apple.com")
    }

    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case clearCacheTapped
            case cacheClearedAlertDismissed
        }

        public enum ReducerAction: Equatable {
            case iisReachability(ReachabilityFeature.Action)
            case appleReachability(ReachabilityFeature.Action)
        }

        public typealias DelegateAction = Never

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.apiClient.clearCache) var clearNetworkCache
    @Dependency(\.imageCache) var imageCache

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.clearCacheTapped):
                state.cacheClearedAlert = AlertState(
                    title: TextState("alert.clearCache.title"),
                    message: TextState("alert.clearCache.message")
                )
                return .fireAndForget {
                    clearNetworkCache()
                    imageCache.clearCache()
                }

            case .view(.cacheClearedAlertDismissed):
                state.cacheClearedAlert = nil
                return .none

            case .reducer:
                return .none
            }
        }

        Scope(state: \.iisReachability, reducerAction: /Action.ReducerAction.iisReachability) {
            ReachabilityFeature()
        }

        Scope(state: \.appleReachability, reducerAction: /Action.ReducerAction.appleReachability) {
            ReachabilityFeature()
        }
    }
}
