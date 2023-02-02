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
    }

    @Dependency(\.premiumService) var premiumService

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return listenToPremiumUpdates()
            case let ._setIsPremium(value):
                state.hasPremium = value
                return .none
            }
        }
    }

    private func listenToPremiumUpdates() -> EffectTask<Action> {
        return .run { send in
            for await value in premiumService.isPremium.removeDuplicates().values {
                await send(._setIsPremium(value))
            }
        }
    }
}
