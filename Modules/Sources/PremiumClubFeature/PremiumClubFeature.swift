import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PremiumClubFeature: ReducerProtocol {
    public enum Source {
        case appIcon
    }

    public struct State: Equatable {
        public var source: Source?
        public var hasPremium: Bool

        public init(source: Source? = nil, hasPremium: Bool = false) {
            self.source = source
            self.hasPremium = hasPremium
        }
    }

    public enum Action: Equatable {
        case _togglePremium
    }

    public init() {}

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
