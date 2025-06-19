import Foundation
import ReachabilityFeature
import ComposableArchitecture

@Reducer
public struct NetworkAndDataFeature {
    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<Action.AlertAction>?
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
                state.alert = .clearCache
                return .run { _ in
                    await clearNetworkCache()
                    await imageCache.clearCache()
                }

            case .clearWhatsNewTapped:
                state.alert = .clearWhatsNew
                return .run { send in
                    whatsNewService.removeAllPresentationMarks()
                    await send(.delegate(.whatsNewCacheCleared))
                }

            case .iisReachability, .appleReachability, .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)

        Scope(state: \.iisReachability, action: \.iisReachability) {
            ReachabilityFeature()
        }

        Scope(state: \.appleReachability, action: \.appleReachability) {
            ReachabilityFeature()
        }
    }
}

// MARK: - AlertState

private extension AlertState where Action == NetworkAndDataFeature.Action.AlertAction {
    static let clearCache = AlertState {
        TextState("alert.clearCache.title")
    } message: {
        TextState("alert.clearCache.message")
    }

    static let clearWhatsNew = AlertState {
        TextState("alert.clearWhatsNewCache.title")
    } message: {
        TextState("alert.clearWhatsNewCache.message")
    }
}
