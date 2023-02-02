import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PremiumClubFeature: ReducerProtocol {
    public enum Source {
        case appIcon
    }

    public struct State: Equatable {
        var source: Source? = nil
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
