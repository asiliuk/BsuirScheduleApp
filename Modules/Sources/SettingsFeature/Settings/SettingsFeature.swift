import Foundation
import BsuirCore
import BsuirUI
import PremiumClubFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies
import SwiftUI

public struct SettingsFeature: Reducer {
    public struct State: Equatable {
        public var path = NavigationPath()
        var isOnTop: Bool = true

        var premiumClub = PremiumClubFeature.State()
        #if DEBUG
        var debugPremiumClubRow = DebugPremiumClubRow.State()
        #endif

        var appIcon = AppIconFeature.State()
        var appearance = AppearanceFeature.State()
        var networkAndData = NetworkAndDataFeature.State()
        var about = AboutFeature.State()

        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case setIsOnTop(Bool)
            case setPath(NavigationPath)
        }
        
        public enum ReducerAction: Equatable {
            case premiumClub(PremiumClubFeature.Action)
            #if DEBUG
            case debugPremiumClubRow(DebugPremiumClubRow.Action)
            #endif

            case appIcon(AppIconFeature.Action)
            case appearance(AppearanceFeature.Action)
            case networkAndData(NetworkAndDataFeature.Action)
            case about(AboutFeature.Action)
        }
        
        public enum DelegateAction: Equatable {
            case showPremiumClub(source: PremiumClubFeature.Source?)
        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(.setIsOnTop(value)):
                state.isOnTop = value
                return .none

            case let .view(.setPath(value)):
                state.path = value
                return .none

            case .reducer(.appIcon(.delegate(let action))):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClub(source: .appIcon)))
                }

            case .reducer, .delegate:
                return .none
            }
        }

        Scope(state: \.premiumClub, reducerAction: /Action.ReducerAction.premiumClub) {
            PremiumClubFeature()
        }

        #if DEBUG
        Scope(state: \.debugPremiumClubRow, reducerAction: /Action.ReducerAction.debugPremiumClubRow) {
            DebugPremiumClubRow()
        }
        #endif

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
        if !path.isEmpty {
            return path = NavigationPath()
        }

        if !isOnTop {
            return isOnTop = true
        }
    }

    public mutating func openPremiumClub(source: PremiumClubFeature.Source?) {
        reset()
        premiumClub.source = source
        path.append(SettingsFeatureDestination.premiumClub)
    }
}
