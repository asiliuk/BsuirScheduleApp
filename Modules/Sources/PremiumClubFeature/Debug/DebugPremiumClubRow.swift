import Foundation
import Dependencies
import ComposableArchitecture
import ComposableArchitectureUtils

#if DEBUG
public struct DebugPremiumClubRow: Reducer {
    public struct State: Equatable {
        var isPremium: Bool = false
        public init() {}
    }

    public enum Action: Equatable {
        case task
        case setIsPremium(Bool)
    }

    @Dependency(\.debugPremiumService) var debugPremiumService

    public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .run { send in
                for await value in debugPremiumService.isPremium.removeDuplicates().values {
                    await send(.setIsPremium(value))
                }
            }

        case let .setIsPremium(value):
            state.isPremium = value
            return .fireAndForget {
                debugPremiumService.isCurrentlyPremium = value
            }
        }
    }
}
#endif
