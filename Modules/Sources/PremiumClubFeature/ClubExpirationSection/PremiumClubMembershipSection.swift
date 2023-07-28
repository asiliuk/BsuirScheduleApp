import Foundation
import ComposableArchitecture

public struct PremiumClubMembershipSection: Reducer {
    public struct State: Equatable {
        var expirationText: TextState {
            let formattedExpiration = expiration?.formatted(date: .long, time: .omitted)
            return TextState("Your subscription will expire \(formattedExpiration ?? "-/-")")
        }
        var expiration: Date?
    }

    public enum Action: Equatable {
        case manageButtonTapped
    }

    @Dependency(\.openURL) var openUrl

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .manageButtonTapped:
                return .fireAndForget { await openUrl(.appStoreSubscriptions) }
            }
        }
    }
}
