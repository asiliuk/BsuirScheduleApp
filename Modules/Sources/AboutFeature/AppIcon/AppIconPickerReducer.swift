import Foundation
import UIKit
import BsuirCore
import ComposableArchitecture

// TODO: Find a way to make internal
public struct AppIconPickerReducer: ReducerProtocol {
    public struct State: Equatable {
        var alert: AlertState<Action>?
        var supportsIconPicking: Bool = true
        var defaultIcon: UIImage?
        var currentIcon: AppIcon = .standard
    }
    
    public enum Action: Equatable {
        case task
        case alertDismissed
        case iconPicked(AppIcon)
        case setSupportsIconPicking(Bool)
        case setCurrentIcon(AppIcon?)
        case iconChanged(AppIcon)
        case iconChangeFailed
    }


    public var body: some ReducerProtocol<State, Action> {
        CurrentAppIconReducer()
        ChangeAppIconReducer()
        ChangeAppIconReportReducer()
    }
}

private struct ChangeAppIconReducer: ReducerProtocol {
    typealias State = AppIconPickerReducer.State
    typealias Action = AppIconPickerReducer.Action
    
    @Dependency(\.application.setAlternateIconName) var setAlternateIconName
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .iconPicked(icon):
                state.currentIcon = icon
                return .task {
                    do {
                        try await setAlternateIconName(icon.name)
                        return .iconChanged(icon)
                    } catch {
                        return .iconChangeFailed
                    }
                }
                
            case .iconChanged(.resist),
                 .iconChanged(.national):
                state.alert =  AlertState(
                    title: TextState("alert.goodIconChoice.title"),
                    message: TextState("alert.goodIconChoice.message")
                )
                return .none
                
            case .iconChanged:
                return .none
                
            case .iconChangeFailed:
                state.alert =  AlertState(
                    title: TextState("alert.iconUpdateFailed.title"),
                    message: TextState("alert.iconUpdateFailed.message")
                )
                return .none
                
            case .alertDismissed:
                state.alert = nil
                return .none
            
            case .task,
                 .setSupportsIconPicking,
                 .setCurrentIcon:
                return .none
            }
        }
    }
}

private struct ChangeAppIconReportReducer: ReducerProtocol {
    typealias State = AppIconPickerReducer.State
    typealias Action = AppIconPickerReducer.Action
    
    @Dependency(\.reviewRequestService) var reviewRequestService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .iconChanged:
                return .fireAndForget { reviewRequestService.madeMeaningfulEvent(.appIconChanged) }
                
            case .task,
                 .alertDismissed,
                 .setSupportsIconPicking,
                 .setCurrentIcon,
                 .iconPicked,
                 .iconChangeFailed:
                return .none
            }
        }
    }
}

private struct CurrentAppIconReducer: ReducerProtocol {
    typealias State = AppIconPickerReducer.State
    typealias Action = AppIconPickerReducer.Action
    
    @Dependency(\.appInfo.iconName) var appIconName
    @Dependency(\.application.supportsAlternateIcons) var supportsAlternateIcons
    @Dependency(\.application.alternateIconName) var alternateIconName

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.defaultIcon = appIconName.flatMap(UIImage.init(named:))
                return .merge(
                    .task { await .setSupportsIconPicking(supportsAlternateIcons()) },
                    .task {
                        let alternateIconName = await alternateIconName()
                        let appIcon = alternateIconName.flatMap(AppIcon.init(name:))
                        return .setCurrentIcon(appIcon)
                    }
                )
                
            case let .setCurrentIcon(appIcon?):
                state.currentIcon = appIcon
                return .none
                
            case .setCurrentIcon(nil):
                return .none
                
            case let .setSupportsIconPicking(value):
                state.supportsIconPicking = value
                return .none
                
            case .alertDismissed,
                 .iconPicked,
                 .iconChanged,
                 .iconChangeFailed:
                return .none
            }
        }
    }
}

// MARK: - Event

private extension MeaningfulEvent {
    static let appIconChanged = Self(score: 5)
}
