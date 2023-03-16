import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

public struct FakeAdsFeature: Reducer {
    public struct State: Equatable {
        let label: TextState
        let title: TextState
        let description: TextState

        public init(label: TextState, title: TextState, description: TextState) {
            self.label = label
            self.title = title
            self.description = description
        }
    }

    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case bannerTapped
        }

        public enum ReducerAction: Equatable {}

        public enum DelegateAction: Equatable {
            case showPremiumClub
        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .view(.bannerTapped):
            return .send(.delegate(.showPremiumClub))
        case .reducer, .delegate:
            return .none
        }
    }
}
