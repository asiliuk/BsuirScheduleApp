import Foundation
import ReachabilityFeature
import ComposableArchitecture

public struct NetworkAndDataFeature: Reducer {
    public struct State: Equatable {
        @PresentationState var alert: AlertState<Action.AlertAction>?
        var iisReachability = ReachabilityFeature.State(host: URL.iisApi.host()!)
        var appleReachability = ReachabilityFeature.State(host: "apple.com")
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case whatsNewCacheCleared
        }
        public typealias AlertAction = Never
        case iisReachability(ReachabilityFeature.Action)
        case appleReachability(ReachabilityFeature.Action)
        case clearCacheTapped
        case clearWhatsNewTapped
        case alert(PresentationAction<AlertAction>)
        case delegate(Delegate)
    }

    @Dependency(\.apiClient.clearCache) var clearNetworkCache
    @Dependency(\.imageCache) var imageCache
    @Dependency(\.whatsNewService) var whatsNewService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clearCacheTapped:
                state.alert = AlertState(
                    title: TextState("alert.clearCache.title"),
                    message: TextState("alert.clearCache.message")
                )
                return .run { _ in
                    await clearNetworkCache()
                    imageCache.clearCache()
                }

            case .clearWhatsNewTapped:
                state.alert = AlertState(
                    title: TextState("alert.clearWhatsNewCache.title"),
                    message: TextState("alert.clearWhatsNewCache.message")
                )
                return .run { send in
                    whatsNewService.removeAllPresentationMarks()
                    await send(.delegate(.whatsNewCacheCleared))
                }

            case .iisReachability, .appleReachability, .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)

        Scope(state: \.iisReachability, action: /Action.iisReachability) {
            ReachabilityFeature()
        }

        Scope(state: \.appleReachability, action: /Action.appleReachability) {
            ReachabilityFeature()
        }
    }
}
