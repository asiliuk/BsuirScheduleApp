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
    }

    public struct State: Equatable {
        public var source: Source?
        public var hasPremium: Bool

        var sections: [Section] {
            let sections: [Section]
            switch source {
            case nil:
                sections = [.pinnedSchedule, .widgets, .appIcons]
            case .appIcon:
                sections = [.appIcons, .pinnedSchedule, .widgets]
            case .pin:
                sections = [.pinnedSchedule, .widgets, .appIcons]
            }

            return hasPremium ? [.tips] + sections : sections + [.tips]
        }

        var tips = TipsSection.State()
        var subsctiptionFooter = SubscriptionFooter.State()

        public init(
            source: Source? = nil,
            hasPremium: Bool? = nil
        ) {
            self.source = source
            @Dependency(\.productsService) var productsService
            self.hasPremium = hasPremium ?? productsService.isCurrentlyPremium
        }
    }

    public enum Action: Equatable {
        case task
        case _setIsPremium(Bool)
        case tips(TipsSection.Action)
        case subsctiptionFooter(SubscriptionFooter.Action)
    }

    @Dependency(\.productsService) var productsService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return listenToPremiumUpdates()
            case let ._setIsPremium(value):
                state.hasPremium = value
                return .none
            default:
                return .none
            }
        }

        Scope(state: \.tips, action: /Action.tips) {
            TipsSection()
        }

        Scope(state: \.subsctiptionFooter, action: /Action.subsctiptionFooter) {
            SubscriptionFooter()
        }
    }

    private func listenToPremiumUpdates() -> Effect<Action> {
        return .run { send in
            for await value in productsService.isPremium.removeDuplicates().values {
                await send(._setIsPremium(value))
            }
        }
    }
}
