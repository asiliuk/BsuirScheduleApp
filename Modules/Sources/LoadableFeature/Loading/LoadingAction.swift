import Foundation

public protocol LoadableAction {
    associatedtype State
    static func loading(_ action: LoadingAction<State>) -> Self
}

public struct LoadingAction<Root>: Equatable {
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

// MARK: - Equatable

extension LoadingAction.Action: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear), (.refresh, .refresh):
            return true
        case (.loadingError(let lhs), .loadingError(let rhs)):
            return lhs == rhs
        case (.delegate(let lhs), .delegate(let rhs)):
            return lhs == rhs
        case let (._loaded(_, lhsIsEqualTo), ._loaded(rhs, _)):
            return lhsIsEqualTo(rhs)
        case let (._loadingFailed(lhs), ._loadingFailed(rhs)):
            return (lhs as NSError) == (rhs as NSError)
        case (._loadingFailed, _), (._loaded, _), (.onAppear, _), (.refresh, _), (.loadingError, _), (.delegate, _):
            return false
        }
    }
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
