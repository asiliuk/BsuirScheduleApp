import Foundation
import BsuirCore
import BsuirUI
import ComposableArchitecture
import Dependencies

public struct AboutFeature: ReducerProtocol {
    public struct State: Equatable {
        var cacheClearedAlert: AlertState<Action>?
        var appVersion: TextState?
        var appIcon = AppIconPickerReducer.State()
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case task
        case clearCacheTapped
        case cacheClearedAlertDismissed
        
        case githubButtonTapped
        case telegramButtonTapped
        
        case appIcon(AppIconPickerReducer.Action)
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
            case .task:
                state.appVersion = TextState("screen.about.aboutTheApp.version.\(appVersion)")
                return .none
                
            case .clearCacheTapped:
                state.cacheClearedAlert = AlertState(
                    title: TextState("alert.clearCache.title"),
                    message: TextState("alert.clearCache.message")
                )
                return .fireAndForget {
                    urlCache.removeAllCachedResponses()
                    imageCache.clearCache()
                }
                
            case .cacheClearedAlertDismissed:
                state.cacheClearedAlert = nil
                return .none
                
            case .githubButtonTapped:
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.githubOpened)
                    _ = await openUrl(.github, [:])
                }
                
            case .telegramButtonTapped:
                return .fireAndForget {
                    reviewRequestService.madeMeaningfulEvent(.telegramOpened)
                    _ = await openUrl(.telegram, [:])
                }
                
            case .appIcon:
                return .none
            }
        }
        
        Scope(state: \.appIcon, action: /Action.appIcon) {
            AppIconPickerReducer()
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
