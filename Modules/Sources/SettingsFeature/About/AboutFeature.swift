import Foundation
import BsuirCore
import ComposableArchitecture
import ComposableArchitectureUtils

public struct AboutFeature: ReducerProtocol {
    public struct State: Equatable {
        var appVersion: String = {
            @Dependency(\.appInfo.version.description) var appVersion
            return appVersion
        }()

    }

    public enum Action: Equatable {
        case githubButtonTapped
        case telegramButtonTapped
    }

    @Dependency(\.openURL) var openUrl
    @Dependency(\.reviewRequestService) var reviewRequestService

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .githubButtonTapped:
            return .fireAndForget {
                reviewRequestService.madeMeaningfulEvent(.githubOpened)
                await openUrl(.github)
            }

        case .telegramButtonTapped:
            return .fireAndForget {
                reviewRequestService.madeMeaningfulEvent(.telegramOpened)
                await openUrl(.telegram)
            }
        }
    }
}

private extension MeaningfulEvent {
    static let githubOpened = Self(score: 1)
    static let telegramOpened = Self(score: 1)
}
