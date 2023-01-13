import Foundation
import UIKit
import BsuirCore
import ComposableArchitecture
import ComposableArchitectureUtils

public struct AppIconFeature: ReducerProtocol {
    public struct State: Equatable {
        var alert: AlertState<Action>?

        var supportsIconPicking: Bool = {
            @Dependency(\.application.supportsAlternateIcons) var supportsAlternateIcons
            return supportsAlternateIcons()
        }()

        var currentIcon: AppIcon? = {
            @Dependency(\.application.alternateIconName) var alternateIconName
            return alternateIconName().flatMap(AppIcon.init(name:)) ?? .plain(.standard)
        }()
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case alertDismissed
            case iconPicked(AppIcon?)
        }
        
        public enum ReducerAction: Equatable {
            case iconChanged(AppIcon?)
            case iconChangeFailed
        }
        
        public typealias DelegateAction = Never
        
        case view(ViewAction)
        case delegate(DelegateAction)
        case reducer(ReducerAction)
    }

    @Dependency(\.application.setAlternateIconName) var setAlternateIconName
    @Dependency(\.reviewRequestService) var reviewRequestService

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .view(.alertDismissed):
            state.alert = nil
            return .none
            
        case let .view(.iconPicked(icon)):
            guard icon != state.currentIcon else {
                return .none
            }

            return .task {
                try await setAlternateIconName(icon?.appIcon.iconName)
                reviewRequestService.madeMeaningfulEvent(.appIconChanged)
                return .reducer(.iconChanged(icon))
            } catch: { _ in
                .reducer(.iconChangeFailed)
            }
            
        case let .reducer(.iconChanged(newIcon)):
            state.currentIcon = newIcon
            if let newIcon, newIcon.showNiceChoiceAlert {
                state.alert =  AlertState(
                    title: TextState("alert.goodIconChoice.title"),
                    message: TextState("alert.goodIconChoice.message")
                )
            }
            return .none
            
        case .reducer(.iconChangeFailed):
            state.alert =  AlertState(
                title: TextState("alert.iconUpdateFailed.title"),
                message: TextState("alert.iconUpdateFailed.message")
            )
            return .none
        }
    }
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

// MARK: - Event

private extension MeaningfulEvent {
    static let appIconChanged = Self(score: 5)
}
