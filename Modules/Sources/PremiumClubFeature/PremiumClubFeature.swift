import Foundation
import ComposableArchitecture
import BsuirCore

@Reducer
public struct PremiumClubFeature {
    public enum Source {
        case pin
        case appIcon
    }

    enum Section: Hashable, Identifiable {
        var id: Self { self }

        case pinnedSchedule
        case widgets
        case appIcons
        case tips
        case premiumClubMembership
    }

    @ObservableState
    public struct State {
        public var source: Source?
        @SharedReader(.isPremiumUser) var isPremiumUser
        var isModal: Bool
        var confettiCounter: Int = 0
        var redeemCodePresent = false

        var sections: [Section] {
            switch source {
            case nil:
                return [.premiumClubMembership, .pinnedSchedule, .widgets, .appIcons, .tips]
            case .pin:
                return [.pinnedSchedule, .premiumClubMembership, .widgets, .appIcons, .tips]
            case .appIcon:
                return [.appIcons, .premiumClubMembership, .pinnedSchedule, .widgets, .tips]
            }
        }

        var tips = TipsSection.State()
        var premiumClubMembership = PremiumClubMembershipSection.State()
        var subsctiptionFooter = SubscriptionFooter.State()

        public init(
            isModal: Bool,
            source: Source? = nil
        ) {
            self.isModal = isModal
            self.source = source
        }
    }

    public enum Action: BindableAction {
        case task
        case restoreButtonTapped
        case redeemCodeButtonTapped
        case tips(TipsSection.Action)
        case premiumClubMembership(PremiumClubMembershipSection.Action)
        case subsctiptionFooter(SubscriptionFooter.Action)

        case _successfullyBecamePremiumUser

        case binding(BindingAction<State>)
    }

    @Dependency(\.productsService) var productsService
    @Dependency(\.isPresented) var isPresented
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .task:
                return listenToPremiumUpdates(state.$isPremiumUser)

            case .restoreButtonTapped:
                return .run { _ in await productsService.restore() }

            case .redeemCodeButtonTapped:
                state.redeemCodePresent = true
                return .none

            case ._successfullyBecamePremiumUser:
                state.confettiCounter += 1
                guard isPresented, state.isModal else { return .none }
                return .run { _ in
                    try await clock.sleep(for: .seconds(3))
                    await dismiss()
                }

            case .tips, .premiumClubMembership, .subsctiptionFooter, .binding:
                return .none
            }
        }

        Scope(state: \.tips, action: \.tips) {
            TipsSection()
        }

        Scope(state: \.premiumClubMembership, action: \.premiumClubMembership) {
            PremiumClubMembershipSection()
        }

        Scope(state: \.subsctiptionFooter, action: \.subsctiptionFooter) {
            SubscriptionFooter()
        }
    }

    private func listenToPremiumUpdates(_ isPremiumUser: SharedReader<Bool>) -> Effect<Action> {
        return .publisher {
            isPremiumUser.publisher
                .prepend(isPremiumUser.wrappedValue)
                .removeDuplicates()
                // Drop first value
                // if user was not premium, next filter would catch change
                // if user was premium next operators would never be called
                .dropFirst()
                // Take first true value, meaning user become premium
                .filter { $0 }
                .first()
                .map { _ in Action._successfullyBecamePremiumUser }
        }
    }
}
