import Foundation

public protocol LoadableAction {
    associatedtype State
    static func loading(_ action: LoadingAction<State>) -> Self
}

public struct LoadingAction<Root> {
    public enum Action {
        public enum ViewAction {
            case task
            case reload
            case refresh
        }
        
        public enum ReducerAction {
            case loaded(set: (inout Root) -> Void)
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

// MARK: - Refresh

extension LoadingAction {
    public static func refresh<Value>(_ keyPath: WritableKeyPath<Root, LoadableState<Value>>) -> Self {
        self.init(keyPath: keyPath, action: .view(.refresh))
    }
}

// MARK: - Pattern Matching

extension LoadingAction {
    public struct PatternMatcher<Value> {
        fileprivate let keyPath: WritableKeyPath<Root, LoadableState<Value>>
        fileprivate let action: Action.DelegateAction

        public static func finished(_ keyPath: WritableKeyPath<Root, LoadableState<Value>>) -> Self {
            Self(keyPath: keyPath, action: .loadingFinished)
        }
    }

    public static func ~= <Value>(
      matcher: PatternMatcher<Value>,
      bindingAction: Self
    ) -> Bool {
        guard
            matcher.keyPath == bindingAction.keyPath,
            case .delegate(matcher.action) = bindingAction.action
        else {
            return false
        }

        return true
    }
}
