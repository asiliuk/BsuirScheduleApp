import Foundation
import ComposableArchitecture
import BsuirCore

@Reducer
public struct LoadingErrorFailedToDecode {
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
    @Dependency(\.appInfo) var appInfo

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .openIssueTapped:
            let url = issueUrl(state)
            return .run { _ in await openUrl(url) }
        }
    }

    private func issueUrl(_ state: State) -> URL {
        return requestIssueUrl(
            title: "Failed to parse",
            address: state.address,
            message: state.message,
            appInfo: appInfo
        )
    }
}

extension Reducer {
    func requestIssueUrl(title: String, address: String, message: String, appInfo: AppInfo) -> URL {
        return .githubIssue(
            title: title,
            body: issueBody(address: address, message: message, appInfo: appInfo),
            labels: "bug", "parsing"
        )
    }

    private func issueBody(address: String, message: String, appInfo: AppInfo) -> String {
        return """
        ## While requesting
        \(address)

        ## Received following error
        ```
        \(message)
        ```

        ## Context
        Version: \(appInfo.version)
        """
    }
}
