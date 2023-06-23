import Foundation
import ComposableArchitecture

public struct FakeAdsFeature: ReducerProtocol {
    public struct State: Equatable {
        public static let oneTimeConfig = FakeAdConfig.all.randomElement()!

        var config: FakeAdConfig
        var image: FakeAdConfig.AdImage { config.image }
        var label: TextState { TextState(config.label) }
        var title: TextState { TextState(config.title) }
        var description: TextState { TextState(config.description) }

        public init(config: FakeAdConfig = oneTimeConfig) {
            self.config = config
        }
    }

    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case showPremiumClub
        }

        case bannerTapped
        case delegate(DelegateAction)
    }

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .bannerTapped:
            return .send(.delegate(.showPremiumClub))
        case .delegate:
            return .none
        }
    }
}
