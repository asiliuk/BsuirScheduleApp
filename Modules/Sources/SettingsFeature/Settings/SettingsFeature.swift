import Foundation
import BsuirCore
import BsuirUI
import PremiumClubFeature
import ComposableArchitecture
import Dependencies
import SwiftUI

@Reducer
public struct SettingsFeature {
    @ObservableState
    public struct State: Equatable {
        public var path = NavigationPath()

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
    
    public enum Action: Equatable, BindableAction {
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

        case delegate(DelegateAction)
        case binding(BindingAction<State>)
    }

    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
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

            case .premiumClub, .whatsNew, .appIcon, .appearance, .networkAndData, .about, .delegate, .binding:
                return .none
            }
        }
        .ifLet(\.whatsNew, action: \.whatsNew) {
            WhatsNewFeature()
        }

        Scope(state: \.premiumClub, action: \.premiumClub) {
            PremiumClubFeature()
        }

        Scope(state: \.appIcon, action: \.appIcon) {
            AppIconFeature()
        }

        Scope(state: \.appearance, action: \.appearance) {
            AppearanceFeature()
        }

        Scope(state: \.networkAndData, action: \.networkAndData) {
            NetworkAndDataFeature()
        }

        Scope(state: \.about, action: \.about) {
            AboutFeature()
        }

        Scope(state: \.roadmap, action: \.roadmap) {
            RoadmapFeature()
        }
    }
}
