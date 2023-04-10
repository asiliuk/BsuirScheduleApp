import Foundation
import ComposableArchitecture

public struct FakeAdsSection: Reducer {
    public struct State: Equatable {
        @PresentationState var alert: AlertState<Action.AlertAction>?
    }

    public enum Action: Equatable {
        public enum AlertAction: Equatable {}

        case whyNotRealAdsTapped
        case alert(PresentationAction<AlertAction>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .whyNotRealAdsTapped:
                state.alert = .whyNotRealAds
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}

private extension AlertState where Action == FakeAdsSection.Action.AlertAction {
    static let whyNotRealAds = AlertState(
        title: TextState("Why not real ads?"),
        message: TextState("It is pretty simple. I don't want to sell your data to corporations and bloat app size with huge 3rd party SDK. And it is a nice place to have some fun in the app.")
    )
}
