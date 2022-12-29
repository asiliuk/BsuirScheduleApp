import Foundation
import BsuirCore
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct SettingsFeature: ReducerProtocol {
    public struct State: Equatable {
        var appIcon = AppIconPickerReducer.State()
        var pairFormsColorPicker = PairFormsColorPicker.State()
        var isOnTop: Bool = true

        var about: AboutFeature.State = .init()
        var networkAndData: NetworkAndDataFeature.State = .init()

        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case setIsOnTop(Bool)
        }
        
        public enum ReducerAction: Equatable {
            case appIcon(AppIconPickerReducer.Action)
            case pairFormsColorPicker(PairFormsColorPicker.Action)
            case about(AboutFeature.Action)
            case networkAndData(NetworkAndDataFeature.Action)
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
        
        Scope(state: \.appIcon, reducerAction: /Action.ReducerAction.appIcon) {
            AppIconPickerReducer()
        }

        Scope(state: \.pairFormsColorPicker, reducerAction: /Action.ReducerAction.pairFormsColorPicker) {
            PairFormsColorPicker()
        }

        Scope(state: \.about, reducerAction: /Action.ReducerAction.about) {
            AboutFeature()
        }

        Scope(state: \.networkAndData, reducerAction: /Action.ReducerAction.networkAndData) {
            NetworkAndDataFeature()
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
