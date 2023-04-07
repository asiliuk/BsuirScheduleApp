import Foundation
import ComposableArchitecture

public struct FakeAdsFeature: Reducer {
    public struct State: Equatable {
        static let config = FakeAdConfig.all.randomElement()!

        var image: FakeAdConfig.AdImage { Self.config.image }
        var label: TextState { TextState(Self.config.label) }
        var title: TextState { TextState(Self.config.title) }
        var description: TextState { TextState(Self.config.description) }

        public init() {}
    }

    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case showPremiumClub
        }

        case bannerTapped
        case delegate(DelegateAction)
    }

    public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .bannerTapped:
            return .send(.delegate(.showPremiumClub))
        case .delegate:
            return .none
        }
    }
}
