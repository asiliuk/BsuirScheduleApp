import Foundation
import ComposableArchitecture
import StoreKit

public struct PremiumClubMembershipSection: Reducer {
    public enum State: Equatable {
        case loading
        case noSubscription
        case subscribed(expiration: Date?, willAutoRenew: Bool)

        init() {
            self = .loading
        }
    }

    public enum Action: Equatable {
        case task
        case manageButtonTapped

        case _premiumStateChanged
        case _failedToGetDetails
        case _receivedNoSubscription
        case _receivedStatus(Product.SubscriptionInfo.Status)
    }

    @Dependency(\.openURL) var openUrl
    @Dependency(\.productsService) var productsService
    @Dependency(\.premiumService) var premiumService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .merge(
                    loadSubscriptionDetails(state: &state),
                    listenForPremiumStateUpdates()
                )
            case .manageButtonTapped:
                return .run { _ in await openUrl(.appStoreSubscriptions) }
            case ._premiumStateChanged:
                return loadSubscriptionDetails(state: &state).animation()
            case ._failedToGetDetails:
                state = .noSubscription
                return .none
            case ._receivedNoSubscription:
                state = .noSubscription
                return .none
            case ._receivedStatus(let status):
                guard
                    case .verified(let transaction) = status.transaction,
                    transaction.revocationDate == nil,
                    case .verified(let renewalInfo) = status.renewalInfo
                else {
                    state = .noSubscription
                    return .none
                }
                state = .subscribed(
                    expiration: transaction.expirationDate,
                    willAutoRenew: renewalInfo.willAutoRenew
                )
                return .none
            }
        }
    }

    private func loadSubscriptionDetails(state: inout State) -> Effect<Action> {
        state = .loading
        return .run { send in
            let subscription = try await productsService.subscription
            guard
                let subscriptionInfo = subscription.subscription,
                let status = try await subscriptionInfo.status.last
            else {
                await send(._receivedNoSubscription)
                return
            }

            await send( ._receivedStatus(status))
        } catch: { _, send in
            await send(._failedToGetDetails)
        }
    }

    private func listenForPremiumStateUpdates() -> Effect<Action> {
        return .run { send in
            for await _ in premiumService.isPremium.removeDuplicates().dropFirst().values {
                await send(._premiumStateChanged)
            }
        }
    }
}
