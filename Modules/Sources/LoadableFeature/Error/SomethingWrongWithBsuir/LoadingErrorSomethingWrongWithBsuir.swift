import Foundation
import BsuirUI
import BsuirCore
import ReachabilityFeature
import ComposableArchitecture

@Reducer
public struct LoadingErrorSomethingWrongWithBsuir {
    @ObservableState
    public struct State: Equatable {
        var reachability: ReachabilityFeature.State?
        var errorCode: String
        var address: String
        var message: String

        init(url: URL?, description: String, statusCode: Int?) {
            self.reachability = url.map { .init(host: $0.host()!) }
            self.address = url?.absoluteString ?? "--"
            self.message = description
            self.errorCode = "\(statusCode ?? 123)"
        }
    }
    public enum Action: Equatable {
        case reachability(ReachabilityFeature.Action)
        case reloadButtonTapped
        case openIssueTapped
    }

    @Dependency(\.openURL) var openUrl
    @Dependency(\.appInfo) var appInfo

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .openIssueTapped:
                let url = issueUrl(state)
                return .run { _ in await openUrl(url) }

            case .reachability, .reloadButtonTapped:
                return .none
            }
        }
        .ifLet(\.reachability, action: \.reachability) {
            ReachabilityFeature()
        }
    }

    private func issueUrl(_ state: State) -> URL {
        return requestIssueUrl(
            title: "Failed to fetch API",
            address: state.address,
            message: state.message,
            appInfo: appInfo
        )
    }
}
