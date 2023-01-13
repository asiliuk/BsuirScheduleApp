import Foundation

extension Optional {
    /// Same as `??` but compiles faster
    public func or(_ other: @autoclosure () -> Wrapped) -> Wrapped {
        switch self {
        case let .some(wrapped):
            return wrapped
        case .none:
            return other()
        }
    }

    /// Same as `??` but compiles faster
    public func or(_ other: @autoclosure () -> Wrapped?) -> Wrapped? {
        switch self {
        case let .some(wrapped):
            return wrapped
        case .none:
            return other()
        }
    }
}
