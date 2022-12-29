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

        var mastodonHandle: String {
            let components = URLComponents(url: .mastodon, resolvingAgainstBaseURL: true)
            return [components?.path.dropFirst(), components?.host?[...]].compactMap { $0 }.joined(separator: "@")
        }
    }

    public enum Action: Equatable {
        case githubButtonTapped
        case telegramButtonTapped
        case mastodonButtonTapped
    }

    @Dependency(\.application.open) var openUrl
    @Dependency(\.reviewRequestService) var reviewRequestService

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
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

        case .mastodonButtonTapped:
            return .fireAndForget {
                reviewRequestService.madeMeaningfulEvent(.mastodonOpened)
                _ = await openUrl(.mastodon, [:])
            }
        }
    }
}

private extension MeaningfulEvent {
    static let githubOpened = Self(score: 1)
    static let telegramOpened = Self(score: 1)
    static let mastodonOpened = Self(score: 1)
}
