import Foundation

public func optionalSort<T, V: Comparable>(_ keyPath: KeyPath<T, V?>) -> (T, T) -> Bool {
    return { lhs, rhs in
        switch (lhs[keyPath: keyPath], rhs[keyPath: keyPath]) {
        case (nil, nil): return false
        case (nil,.some): return true
        case (.some, nil): return false
        case let (lhs?, rhs?): return lhs < rhs
        }
    }
}
