import Foundation
import ComposableArchitecture
import StoreKit

@Reducer
public struct PremiumClubMembershipSection {
    @Reducer(state: .equatable, action: .equatable)
    public enum MembershipSubscription {
        case loading
        case noSubscription
        case subscribed(PremiumClubMembershipSubscribed)
    }

    @ObservableState
    public struct State: Equatable {
        var subscription: MembershipSubscription.State = .loading
        @SharedReader(.isPremiumUser) var isPremiumUser

        public init() {}
    }

    public enum Action: Equatable {
        case task

        case _premiumStateChanged
        case _failedToGetDetails
        case _receivedNoSubscription
        case _receivedStatus(Product.SubscriptionInfo.Status)

        case subscription(MembershipSubscription.Action)
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .merge(
                    loadSubscriptionDetails(state: &state),
                    listenForPremiumStateUpdates(state.$isPremiumUser)
                )
            case ._premiumStateChanged:
                return loadSubscriptionDetails(state: &state).animation()
            case ._failedToGetDetails:
                state.subscription = .noSubscription
                return .none
            case ._receivedNoSubscription:
                state.subscription = .noSubscription
                return .none
            case ._receivedStatus(let status):
                guard
                    case .verified(let transaction) = status.transaction,
                    transaction.revocationDate == nil,
                    case .verified(let renewalInfo) = status.renewalInfo
                else {
                    state.subscription = .noSubscription
                    return .none
                }
                state.subscription = .subscribed(.init(
                    expiration: transaction.expirationDate,
                    willAutoRenew: renewalInfo.willAutoRenew
                ))
                return .none

            case .subscription:
                return .none
            }
        }

        Scope(state: \.subscription, action: \.subscription) {
            MembershipSubscription.body
        }
    }

    private func loadSubscriptionDetails(state: inout State) -> Effect<Action> {
        state.subscription = .loading
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

    private func listenForPremiumStateUpdates(_ isPremiumUser: SharedReader<Bool>) -> Effect<Action> {
        return .publisher {
            isPremiumUser.publisher
                .map { _ in ._premiumStateChanged }
        }
    }
}

@Reducer
public struct PremiumClubMembershipSubscribed {
    @ObservableState
    public struct State: Equatable {
        var formattedExpiration: String { expiration?.formatted(date: .long, time: .omitted) ?? "-/-" }
        var expiration: Date?
        var willAutoRenew: Bool
        var manageSubscriptionPresented: Bool = false
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
