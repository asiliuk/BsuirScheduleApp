import Foundation
import BsuirCore
import ComposableArchitecture

public struct AboutFeature: Reducer {
    public struct State: Equatable {
        var appVersion: String = {
            @Dependency(\.appInfo.version.description) var appVersion
            return appVersion
        }()

    }

    public enum Action: Equatable {
        case githubButtonTapped
        case telegramButtonTapped
        case reviewButtonTapped
        case privacyPolicyTapped
        case termsAndConditionsTapped
    }

    @Dependency(\.openURL) var openUrl
    @Dependency(\.reviewRequestService) var reviewRequestService

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .githubButtonTapped:
            return .run { _ in
                await reviewRequestService.madeMeaningfulEvent(.githubOpened)
                await openUrl(.github)
            }

        case .telegramButtonTapped:
            return .run { _ in
                await reviewRequestService.madeMeaningfulEvent(.telegramOpened)
                await openUrl(.telegram)
            }

        case .reviewButtonTapped:
            return .run { _ in
                await openUrl(.appStoreReview)
            }

        case .privacyPolicyTapped:
            return .run { _ in
                await openUrl(.privacyPolicy)
            }

        case .termsAndConditionsTapped:
            return .run { _ in
                await openUrl(.termsAndConditions)
            }
        }
    }
}

private extension MeaningfulEvent {
    static let githubOpened = Self(score: 1)
    static let telegramOpened = Self(score: 1)
}
