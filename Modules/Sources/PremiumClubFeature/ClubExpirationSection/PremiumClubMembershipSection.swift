import Foundation
import ComposableArchitecture
import StoreKit

public struct PremiumClubMembershipSection: Reducer {
    public enum State: Equatable {
        case loading
        case noSubscription
        case subscribed(PremiumClubMembershipSubscribed.State)

        init() {
            self = .loading
        }
    }

    public enum Action: Equatable {
        case task

        case _premiumStateChanged
        case _failedToGetDetails
        case _receivedNoSubscription
        case _receivedStatus(Product.SubscriptionInfo.Status)

        case subscribed(PremiumClubMembershipSubscribed.Action)
    }

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
                state = .subscribed(.init(
                    expiration: transaction.expirationDate,
                    willAutoRenew: renewalInfo.willAutoRenew
                ))
                return .none

            case .subscribed:
                return .none
            }
        }

        Scope(state: /State.subscribed, action: /Action.subscribed) {
            PremiumClubMembershipSubscribed()
        }
    }

    private func loadSubscriptionDetails(state: inout State) -> Effect<Action> {
        state = .loading
        return .run { send in
            guard let status = await productsService.subscriptionStatus else {
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

public struct PremiumClubMembershipSubscribed: Reducer {
    public struct State: Equatable {
        var formattedExpiration: String { expiration?.formatted(date: .long, time: .omitted) ?? "-/-" }
        var expiration: Date?
        var willAutoRenew: Bool
        @BindingState var manageSubscriptionPresented: Bool = false
    }

    public enum Action: Equatable, BindableAction {
        case manageButtonTapped
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .manageButtonTapped:
                state.manageSubscriptionPresented = true
                return .none
            case .binding:
                return .none
            }
        }
    }
}
