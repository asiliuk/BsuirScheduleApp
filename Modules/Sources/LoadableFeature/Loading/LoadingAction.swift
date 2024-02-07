import Foundation
import ComposableArchitecture

public protocol LoadableAction {
    associatedtype State
    static func loading(_ action: LoadingAction<State>) -> Self
}

public struct LoadingAction<Root>: Equatable {
    @CasePathable
    public enum Action {
        public enum DelegateAction: Equatable {
            case loadingStarted
            case loadingFinished
        }

        case onAppear
        case refresh
        case loadingError(LoadingError.Action)

        case _loaded(Any, isEqualTo: (Any) -> Bool)
        case _loadingFailed(Error)

        case delegate(DelegateAction)
    }

    let keyPath: PartialKeyPath<Root>
    let action: Action
}

// MARK: - Refresh

extension LoadingAction {
    public static func refresh<Value>(_ keyPath: WritableKeyPath<Root, LoadableState<Value>>) -> Self {
        self.init(keyPath: keyPath, action: .refresh)
    }

    public static func started<Value>(_ keyPath: WritableKeyPath<Root, LoadableState<Value>>) -> Self {
        self.init(keyPath: keyPath, action: .delegate(.loadingStarted))
    }

    public static func finished<Value>(_ keyPath: WritableKeyPath<Root, LoadableState<Value>>) -> Self {
        self.init(keyPath: keyPath, action: .delegate(.loadingFinished))
    }
}
