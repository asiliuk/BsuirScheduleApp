import Foundation
import BsuirCore
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct AboutFeature: ReducerProtocol {
    public struct State: Equatable {
        var cacheClearedAlert: AlertState<Action>?
        var appVersion: TextState?
        var appIcon = AppIconPickerReducer.State()
        var pairFormsColorPicker = PairFormsColorPicker.State()

        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case task
            case clearCacheTapped
            case cacheClearedAlertDismissed
            
            case githubButtonTapped
            case telegramButtonTapped
        }
        
        public enum ReducerAction: Equatable {
            case appIcon(AppIconPickerReducer.Action)
            case pairFormsColorPicker(PairFormsColorPicker.Action)
        }
        
        public typealias DelegateAction = Never

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.urlCache) var urlCache
    @Dependency(\.imageCache) var imageCache
    @Dependency(\.appInfo.version.description) var appVersion
    @Dependency(\.application.open) var openUrl
    @Dependency(\.reviewRequestService) var reviewRequestService

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                state.appVersion = TextState("screen.about.aboutTheApp.version.\(appVersion)")
                return .none
                
            case .view(.clearCacheTapped):
                state.cacheClearedAlert = AlertState(
                    title: TextState("alert.clearCache.title"),
                    message: TextState("alert.clearCache.message")
                )
                return .fireAndForget {
                    urlCache.removeAllCachedResponses()
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
        
        Scope(state: \.appIcon, action: /Action.ReducerAction.appIcon) {
            AppIconPickerReducer()
        }

        Scope(state: \.pairFormsColorPicker, action: /Action.ReducerAction.pairFormsColorPicker) {
            PairFormsColorPicker()
        }
    }
}

private extension URL {
    static let github = URL(string: "https://github.com/asiliuk/BsuirScheduleApp")!
    static let telegram = URL(string: "https://t.me/bsuirschedule")!
}

private extension MeaningfulEvent {
    static let githubOpened = Self(score: 1)
    static let telegramOpened = Self(score: 1)
}
