import Foundation
import BsuirCore
import BsuirUI
import ReachabilityFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct AboutFeature: ReducerProtocol {
    public struct State: Equatable {
        var cacheClearedAlert: AlertState<Action>?
        var appVersion: TextState = {
            @Dependency(\.appInfo.version.description) var appVersion
            return TextState("screen.about.aboutTheApp.version.\(appVersion)")
        }()
        var appIcon = AppIconPickerReducer.State()
        var pairFormsColorPicker = PairFormsColorPicker.State()
        var isOnTop: Bool = true
        var iisReachability = ReachabilityFeature.State(host: URL.iisApi.bsr_host)
        var appleReachability = ReachabilityFeature.State(host: "apple.com")

        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case setIsOnTop(Bool)

            case clearCacheTapped
            case cacheClearedAlertDismissed
            
            case githubButtonTapped
            case telegramButtonTapped
        }
        
        public enum ReducerAction: Equatable {
            case appIcon(AppIconPickerReducer.Action)
            case pairFormsColorPicker(PairFormsColorPicker.Action)
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
    @Dependency(\.application.open) var openUrl
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.networkReachabilityTracker) var networkReachabilityTracker

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(.setIsOnTop(value)):
                state.isOnTop = value
                return .none

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
                
            case .view(.githubButtonTapped):
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.githubOpened)
                    _ = await openUrl(.github, [:])
                }
                
            case .view(.telegramButtonTapped):
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.telegramOpened)
                    _ = await openUrl(.telegram, [:])
                }
                
            case .reducer:
                return .none
            }
        }
        
        Scope(state: \.appIcon, reducerAction: /Action.ReducerAction.appIcon) {
            AppIconPickerReducer()
        }

        Scope(state: \.pairFormsColorPicker, reducerAction: /Action.ReducerAction.pairFormsColorPicker) {
            PairFormsColorPicker()
        }

        Scope(state: \.iisReachability, reducerAction: /Action.ReducerAction.iisReachability) {
            ReachabilityFeature()
        }

        Scope(state: \.appleReachability, reducerAction: /Action.ReducerAction.appleReachability) {
            ReachabilityFeature()
        }
    }
}

private extension MeaningfulEvent {
    static let githubOpened = Self(score: 1)
    static let telegramOpened = Self(score: 1)
}

// MARK: - Reset

extension AboutFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if !isOnTop {
            return isOnTop = true
        }
    }
}
