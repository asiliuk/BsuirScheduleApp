import Foundation
import ComposableArchitecture

public struct PremiumClubFeature: Reducer {
    public enum Source {
        case pin
        case appIcon
        case fakeAds
    }

    enum Section: Hashable, Identifiable {
        var id: Self { self }

        case fakeAds
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
                sections = [.fakeAds, .pinnedSchedule, .widgets, .appIcons]
            case .appIcon:
                sections = [.appIcons, .pinnedSchedule, .fakeAds, .widgets]
            case .pin:
                sections = [.pinnedSchedule, .fakeAds, .widgets, .appIcons]
            case .fakeAds:
                sections = [.fakeAds, .pinnedSchedule, .widgets, .appIcons]
            }

            return hasPremium ? [.tips] + sections : sections + [.tips]
        }

        var fakeAds = FakeAdsSection.State()

        #if DEBUG
        var debugRow = DebugPremiumClubRow.State()
        #endif

        public init(
            source: Source? = nil,
            hasPremium: Bool? = nil
        ) {
            self.source = source
            @Dependency(\.premiumService) var premiumService
            self.hasPremium = hasPremium ?? premiumService.isCurrentlyPremium
        }
    }

    public enum Action: Equatable {
        case task
        case _setIsPremium(Bool)
        #if DEBUG
        case debugRow(DebugPremiumClubRow.Action)
        #endif
        case fakeAds(FakeAdsSection.Action)
    }

    @Dependency(\.premiumService) var premiumService

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

        #if DEBUG
        Scope(state: \.debugRow, action: /Action.debugRow) {
            DebugPremiumClubRow()
        }
        #endif

        Scope(state: \.fakeAds, action: /Action.fakeAds) {
            FakeAdsSection()
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
