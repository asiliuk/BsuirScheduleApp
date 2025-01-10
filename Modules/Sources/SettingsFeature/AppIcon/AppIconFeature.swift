import Foundation
import UIKit
import BsuirCore
import BsuirUI
import ComposableArchitecture

@Reducer
public struct AppIconFeature {
    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<Action.AlertAction>?
        @Shared(.appIcon) var currentIcon
        @SharedReader(.isPremiumUser) var isPremiumUser
    }
    
    public enum Action: Equatable {
        public enum AlertAction: Equatable {
            case learnAboutPremiumClubButtonTapped
        }

        public enum DelegateAction: Equatable {
            case showPremiumClub
        }

        case iconPicked(AppIcon?)
        
        case _iconChanged(AppIcon?)
        case _iconChangeFailed

        case delegate(DelegateAction)
        case alert(PresentationAction<AlertAction>)
    }

    @Dependency(\.application.setAlternateIconName) var setAlternateIconName
    @Dependency(\.reviewRequestService) var reviewRequestService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.learnAboutPremiumClubButtonTapped)):
                return .send(.delegate(.showPremiumClub))

            case let .iconPicked(icon):
                guard icon != state.currentIcon else {
                    return .none
                }

                if let icon, !state.isPremiumUser, icon.isPremium {
                    state.alert = .premiumLocked
                    return .none
                }

                return .run { send in
                    try await setAlternateIconName(icon?.iconName)
                    await reviewRequestService.madeMeaningfulEvent(.appIconChanged)
                    await send(._iconChanged(icon))
                } catch: { _, send in
                    await send(._iconChangeFailed)
                }

            case let ._iconChanged(newIcon):
                state.currentIcon = newIcon
                if let newIcon, newIcon.showNiceChoiceAlert {
                    state.alert = .goodIconChoice
                }
                return .none

            case ._iconChangeFailed:
                state.alert = .iconUpdateFailed
                return .none

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - AlertState

private extension AlertState where Action == AppIconFeature.Action.AlertAction {
    static let premiumLocked = AlertState(
        title: TextState("alert.premiumClub.appIconChange.title"),
        message: TextState("alert.premiumClub.appIconChange.message"),
        buttons: [
            .default(
                TextState("alert.premiumClub.appIconChange.button"),
                action: .send(.learnAboutPremiumClubButtonTapped)
            ),
            .cancel(TextState("alert.premiumClub.appIconChange.cancel"))
        ]
    )

    static let goodIconChoice = AlertState(
        title: TextState("alert.goodIconChoice.title"),
        message: TextState("alert.goodIconChoice.message")
    )

    static let iconUpdateFailed = AlertState(
        title: TextState("alert.iconUpdateFailed.title"),
        message: TextState("alert.iconUpdateFailed.message")
    )
}

// MARK: - AppIcon

private extension AppIcon {
    var showNiceChoiceAlert: Bool {
        switch self {
        case .symbol(.resist), .symbol(.national):
            return true
        default:
            return false
        }
    }
}

extension PersistenceKey where Self == PersistenceKeyDefault<InMemoryKey<AppIcon?>> {
    static var appIcon: Self {
        @Dependency(\.application.alternateIconName) var alternateIconName
        return PersistenceKeyDefault(
            .inMemory("current-app-icon"),
            alternateIconName().flatMap(AppIcon.init(name:)) ?? .plain(.standard)
        )
    }
}

// MARK: - Event

private extension MeaningfulEvent {
    static let appIconChanged = Self(score: 5)
}
