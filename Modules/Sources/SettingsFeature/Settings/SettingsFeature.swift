import Foundation
import BsuirCore
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct SettingsFeature: ReducerProtocol {
    public struct State: Equatable {
        var isOnTop: Bool = true

        var premiumClub = PremiumClubFeature.State()
        var appIcon = AppIconFeature.State()
        var appearance = AppearanceFeature.State()
        var networkAndData = NetworkAndDataFeature.State()
        var about = AboutFeature.State()

        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case setIsOnTop(Bool)
        }
        
        public enum ReducerAction: Equatable {
            case premiumClub(PremiumClubFeature.Action)
            case appIcon(AppIconFeature.Action)
            case appearance(AppearanceFeature.Action)
            case networkAndData(NetworkAndDataFeature.Action)
            case about(AboutFeature.Action)
        }
        
        public typealias DelegateAction = Never

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(.setIsOnTop(value)):
                state.isOnTop = value
                return .none
                
            case .reducer:
                return .none
            }
        }

        Scope(state: \.premiumClub, reducerAction: /Action.ReducerAction.premiumClub) {
            PremiumClubFeature()
        }

        Scope(state: \.appIcon, reducerAction: /Action.ReducerAction.appIcon) {
            AppIconFeature()
        }

        Scope(state: \.appearance, reducerAction: /Action.ReducerAction.appearance) {
            AppearanceFeature()
        }

        Scope(state: \.networkAndData, reducerAction: /Action.ReducerAction.networkAndData) {
            NetworkAndDataFeature()
        }

        Scope(state: \.about, reducerAction: /Action.ReducerAction.about) {
            AboutFeature()
        }
    }
}

// MARK: - Reset

extension SettingsFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if !isOnTop {
            return isOnTop = true
        }
    }
}
