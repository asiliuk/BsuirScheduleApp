import Foundation
import ComposableArchitecture

public struct LoadingErrorFailedToDecode: Reducer {
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

    @Dependency(\.openURL) var openUrl

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .openIssueTapped:
            let url = issueUrl(state)
            return .fireAndForget { await openUrl(url) }
        }
    }

    private func issueUrl(_ state: State) -> URL {
        return requestIssueUrl(
            title: "Failed to parse",
            address: state.address,
            message: state.message
        )
    }
}

extension ReducerProtocol {
    func requestIssueUrl(title: String, address: String, message: String) -> URL {
        return .githubIssue(
            title: title,
            body: issueBody(address: address, message: message),
            labels: "bug", "parsing"
        )
    }

    private func issueBody(address: String, message: String) -> String {
        return """
        ## While requesting
        \(address)

        ## Received following error
        ```
        \(message)
        ```
        """
    }
}
