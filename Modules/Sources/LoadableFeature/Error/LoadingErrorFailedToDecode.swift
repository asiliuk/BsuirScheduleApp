import Foundation
import ComposableArchitecture

public struct LoadingErrorFailedToDecode: ReducerProtocol {
    public struct State: Equatable {
        var address: String
        var message: String

        init(url: URL?, description: String) {
            self.address = url?.absoluteString ?? "--"
            self.message = description
        }
    }

    public enum Action: Equatable {
        case openIssueTapped
    }

    @Dependency(\.application.open) var openUrl

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .openIssueTapped:
            let url = issueUrl(state)
            return .fireAndForget {
                _ = await openUrl(url, [:])
            }
        }
    }

    private func issueUrl(_ state: State) -> URL {
        return .githubIssue(
            title: "Failed to parse",
            body: issueBody(state),
            labels: "bug", "parsing"
        )
    }

    private func issueBody(_ state: State) -> String {
        return """
        ## While requesting
        \(state.address)

        ## Received following error
        ```
        \(state.message)
        ```
        """
    }
}
