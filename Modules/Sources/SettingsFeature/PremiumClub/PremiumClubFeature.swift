import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PremiumClubFeature: ReducerProtocol {
    public struct State: Equatable {
        var hasPremium: Bool = false
    }

    public enum Action: Equatable {
        case _togglePremium
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case ._togglePremium:
                state.hasPremium.toggle()
                return .none
            }
        }
    }
}
