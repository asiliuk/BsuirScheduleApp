import Foundation
import UIKit
import BsuirCore
import ComposableArchitecture
import ComposableArchitectureUtils

// TODO: Find a way to make internal
public struct AppIconPickerReducer: ReducerProtocol {
    public struct State: Equatable {
        var alert: AlertState<Action>?
        var supportsIconPicking: Bool = true
        var defaultIcon: UIImage?
        var currentIcon: AppIcon = .standard
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case task
            case alertDismissed
            case iconPicked(AppIcon)
        }
        
        public enum ReducerAction: Equatable {
            case setSupportsIconPicking(Bool)
            case setCurrentIcon(AppIcon?)
            case iconChanged(AppIcon)
            case iconChangeFailed
        }
        
        public typealias DelegateAction = Never
        
        case view(ViewAction)
        case delegate(DelegateAction)
        case reducer(ReducerAction)
    }

    @Dependency(\.appInfo.iconName) var appIconName
    @Dependency(\.application.supportsAlternateIcons) var supportsAlternateIcons
    @Dependency(\.application.alternateIconName) var alternateIconName
    @Dependency(\.application.setAlternateIconName) var setAlternateIconName
    @Dependency(\.reviewRequestService) var reviewRequestService

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .view(.task):
            state.defaultIcon = appIconName.flatMap(UIImage.init(named:))
            return .merge(
                .task { await checkIfIconPickingSupported() },
                .task { await updateInitialAppIcon() }
            )
            
        case .view(.alertDismissed):
            state.alert = nil
            return .none
            
        case let .view(.iconPicked(icon)):
            guard icon != state.currentIcon else {
                return .none
            }
            
            state.currentIcon = icon
            return .merge(
                .fireAndForget { reviewRequestService.madeMeaningfulEvent(.appIconChanged) },
                .task { await updateAppIcon(icon) }
            )
            
        case let .reducer(.setSupportsIconPicking(value)):
            state.supportsIconPicking = value
            return .none
            
        case let .reducer(.setCurrentIcon(appIcon?)):
            state.currentIcon = appIcon
            return .none
            
        case .reducer(.setCurrentIcon(nil)):
            return .none
            
        case let .reducer(.iconChanged(newIcon)):
            if newIcon.showNiceChoiceAlert {
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
    
    private func checkIfIconPickingSupported() async -> Action {
        await .reducer(.setSupportsIconPicking(supportsAlternateIcons()))
    }
    
    private func updateInitialAppIcon() async -> Action {
        let alternateIconName = await alternateIconName()
        let appIcon = alternateIconName.flatMap(AppIcon.init(name:))
        return .reducer(.setCurrentIcon(appIcon))
    }
    
    private func updateAppIcon(_ icon: AppIcon) async -> Action {
        do {
            try await setAlternateIconName(icon.name)
            return .reducer(.iconChanged(icon))
        } catch {
            return .reducer(.iconChangeFailed)
        }
    }
}

// MARK: - AppIcon

private extension AppIcon {
    var showNiceChoiceAlert: Bool {
        switch self {
        case .resist, .national:
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
