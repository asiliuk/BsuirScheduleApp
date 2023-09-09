import Foundation
import BsuirCore
import BsuirUI
import PremiumClubFeature
import ComposableArchitecture
import Dependencies
import SwiftUI

public struct SettingsFeature: Reducer {
    public struct State: Equatable {
        public var path = NavigationPath()
        var isOnTop: Bool = true

        var premiumClub = PremiumClubFeature.State(isModal: false)

        public var hasWhatsNew: Bool { whatsNew != nil }
        var whatsNew = WhatsNewFeature.State()

        var appIcon = AppIconFeature.State()
        var appearance = AppearanceFeature.State()
        var networkAndData = NetworkAndDataFeature.State()
        var about = AboutFeature.State()
        var roadmap = RoadmapFeature.State()

        public init() {}
    }
    
    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case showPremiumClub(source: PremiumClubFeature.Source?)
        }

        case premiumClub(PremiumClubFeature.Action)
        case whatsNew(WhatsNewFeature.Action)
        case appIcon(AppIconFeature.Action)
        case appearance(AppearanceFeature.Action)
        case networkAndData(NetworkAndDataFeature.Action)
        case about(AboutFeature.Action)
        case roadmap(RoadmapFeature.Action)

        case setIsOnTop(Bool)
        case setPath(NavigationPath)

        case delegate(DelegateAction)
    }

    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setIsOnTop(value):
                state.isOnTop = value
                return .none

            case let .setPath(value):
                state.path = value
                return .none

            case .appIcon(.delegate(let action)):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClub(source: .appIcon)))
                }

            case .whatsNew(.delegate(let action)):
                switch action {
                case .whatsNewDismissed:
                    state.whatsNew = nil
                    return .none
                }

            case .networkAndData(.delegate(let action)):
                switch action {
                case .whatsNewCacheCleared:
                    state.whatsNew = WhatsNewFeature.State()
                    return .none
                }

            case .premiumClub, .whatsNew, .appIcon, .appearance, .networkAndData, .about, .delegate:
                return .none
            }
        }
        .ifLet(\.whatsNew, action: /Action.whatsNew) {
            WhatsNewFeature()
        }

        Scope(state: \.premiumClub, action: /Action.premiumClub) {
            PremiumClubFeature()
        }

        Scope(state: \.appIcon, action: /Action.appIcon) {
            AppIconFeature()
        }

        Scope(state: \.appearance, action: /Action.appearance) {
            AppearanceFeature()
        }

        Scope(state: \.networkAndData, action: /Action.networkAndData) {
            NetworkAndDataFeature()
        }

        Scope(state: \.about, action: /Action.about) {
            AboutFeature()
        }

        Scope(state: \.roadmap, action: /Action.roadmap) {
            RoadmapFeature()
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
