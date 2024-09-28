import Foundation
import BsuirCore
import BsuirUI
import PremiumClubFeature
import ComposableArchitecture
import Dependencies
import SwiftUI
import WhatsNewKit

@Reducer
public struct SettingsFeature {
    @ObservableState
    public struct State: Equatable {
        public var hasWhatsNew: Bool { whatsNew != nil }
        var whatsNew: WhatsNew?

        var premiumClubLabel = PremiumClubLabel.State()
        var appIconLabel = AppIconLabel.State()

        @Presents var destination: Destination.State?
        var selectedDestination: SettingsFeatureDestination?

        public init() {}
    }
    
    public enum Action: Equatable, BindableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClub(source: PremiumClubFeature.Source?)
        }

        case onAppear

        case premiumClubLabel(PremiumClubLabel.Action)
        case appIconLabel(AppIconLabel.Action)

        case destination(PresentationAction<Destination.Action>)

        case delegate(DelegateAction)
        case binding(BindingAction<State>)
    }

    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case premiumClub(PremiumClubFeature)
        case whatsNew(WhatsNewFeature)
        case appIcon(AppIconFeature)
        case appearance(AppearanceFeature)
        case networkAndData(NetworkAndDataFeature)
        case about(AboutFeature)
        case roadmap(RoadmapFeature)
    }

    public init() {}

    @Dependency(\.whatsNewService) var whatsNewService

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.selectedDestination) { _, newValue in
                Reduce { state, _ in
                    state.destination = newValue.flatMap(Destination.State.init)
                    return .none
                }
            }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.whatsNew = whatsNewService.whatsNew()
                return .none

            case .destination(.presented(.networkAndData(.delegate(let action)))):
                switch action {
                case .whatsNewCacheCleared:
                    state.whatsNew = whatsNewService.whatsNew()
                    return .none
                }

            case .destination(.presented(.appIcon(.delegate(let action)))):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClub(source: .appIcon)))
                }

            case .destination(.dismiss):
                guard case .whatsNew(let whatsNewState) = state.destination else { return .none }
                state.whatsNew = nil
                return .run { [version = whatsNewState.whatsNew.version] _ in
                    whatsNewService.markWhatsNewPresented(version: version)
                }

            case .appIconLabel, .delegate, .binding, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)


        Scope(state: \.premiumClubLabel, action: \.premiumClubLabel) {
            PremiumClubLabel()
        }

        Scope(state: \.appIconLabel, action: \.appIconLabel) {
            AppIconLabel()
        }
    }
}

private extension SettingsFeature.Destination.State {
    init?(selection: SettingsFeatureDestination) {
        switch selection {
        case .premiumClub:
            self = .premiumClub(PremiumClubFeature.State(isModal: false))
        case .appIcon:
            self = .appIcon(AppIconFeature.State())
        case .appearance:
            self = .appearance(AppearanceFeature.State())
        case .networkAndData:
            self = .networkAndData(NetworkAndDataFeature.State())
        case .about:
            self = .about(AboutFeature.State())
        case .roadmap:
            self = .roadmap(RoadmapFeature.State())
        }
    }
}
