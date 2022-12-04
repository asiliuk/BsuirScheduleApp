import Foundation
import ComposableArchitecture

extension Store {
    /// Creates a memoized cache that always returns the last non-`nil` value.
    ///
    /// Useful for preserving a presented UI during the programmatic dismissal of sheets and other forms
    /// of navigation, where setting state to `nil` drives dismissal.
    public func returningLastNonNilState<Wrapped>() -> Store<State, Action> where State == Wrapped? {
        var lastWrapped: Wrapped?
        return scope { state in
            if let wrapped = state {
                lastWrapped = wrapped
            }
            return lastWrapped
        }
    }
}
