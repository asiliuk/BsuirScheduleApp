import Foundation
import ComposableArchitecture

public struct PremiumClubFeature: Reducer {
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

    public struct State: Equatable {
        public var source: Source?
        public var hasPremium: Bool
        var isModal: Bool
        var confettiCounter: Int = 0

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
            source: Source? = nil,
            hasPremium: Bool? = nil
        ) {
            self.isModal = isModal
            self.source = source
            @Dependency(\.premiumService) var premiumService
            self.hasPremium = hasPremium ?? premiumService.isCurrentlyPremium
        }
    }

    public enum Action: Equatable {
        case task
        case restoreButtonTapped
        case setConfettiCounter(Int)
        case _setIsPremium(Bool)
        case tips(TipsSection.Action)
        case premiumClubMembership(PremiumClubMembershipSection.Action)
        case subsctiptionFooter(SubscriptionFooter.Action)
    }

    @Dependency(\.productsService) var productsService
    @Dependency(\.premiumService) var premiumService
    @Dependency(\.isPresented) var isPresented
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return listenToPremiumUpdates()

            case .restoreButtonTapped:
                return .run { _ in await productsService.restore() }

            case let ._setIsPremium(value):
                guard value != state.hasPremium else { return .none }
                state.hasPremium = value
                guard value else { return .none }
                state.confettiCounter += 1
                guard isPresented, state.isModal else { return .none }
                return .run { _ in
                    try await clock.sleep(for: .seconds(3))
                    await dismiss()
                }

            case .setConfettiCounter(let value):
                state.confettiCounter = value
                return .none

            default:
                return .none
            }
        }

        Scope(state: \.tips, action: /Action.tips) {
            TipsSection()
        }

        Scope(state: \.premiumClubMembership, action: /Action.premiumClubMembership) {
            PremiumClubMembershipSection()
        }

        Scope(state: \.subsctiptionFooter, action: /Action.subsctiptionFooter) {
            SubscriptionFooter()
        }
    }

    private func listenToPremiumUpdates() -> Effect<Action> {
        return .run { send in
            for await value in premiumService.isPremium.removeDuplicates().values {
                await send(._setIsPremium(value))
            }
        }
    }
}
