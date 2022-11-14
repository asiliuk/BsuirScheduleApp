import Foundation

public protocol LoadableAction {
    associatedtype State
    static func loading(_ action: LoadingAction<State>) -> Self
}

public struct LoadingAction<Root>: Equatable {
    public enum Action: Equatable {
        public enum ViewAction: Equatable {
            case task
            case reload
            case refresh
        }
        
        public enum ReducerAction {
            case loaded(Any, isEqualTo: (Any) -> Bool)
            case loadingFailed
        }
        
        public enum DelegateAction: Equatable {
            case loadingFinished
        }
        
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }
    
    let keyPath: PartialKeyPath<Root>
    let action: Action
}

// MARK: - Equatable

extension LoadingAction.Action.ReducerAction: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.loaded(_, lhsIsEqualTo), .loaded(rhs, _)):
            return lhsIsEqualTo(rhs)
        case (.loadingFailed, .loadingFailed):
            return true
        case (.loadingFailed, .loaded), (.loaded, .loadingFailed):
            return false
        }
    }
}

// MARK: - Refresh

extension LoadingAction {
    public static func refresh<Value>(_ keyPath: WritableKeyPath<Root, LoadableState<Value>>) -> Self {
        self.init(keyPath: keyPath, action: .view(.refresh))
    }
    
    public static func finished<Value>(_ keyPath: WritableKeyPath<Root, LoadableState<Value>>) -> Self {
        self.init(keyPath: keyPath, action: .delegate(.loadingFinished))
    }
}
