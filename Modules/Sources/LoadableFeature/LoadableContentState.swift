import Foundation

public enum LodableContentState<Value> {
    case initial
    case loading
    case error
    case some(Value)
    
    public init() {
        self = .initial
    }
}

// MARK: - Equatable

extension LodableContentState: Equatable where Value: Equatable {}

// MARK: - Transform

extension LodableContentState {

    public func map<U>(_ transform: (Value) -> U) -> LodableContentState<U> {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case .error: return .error
        case let .some(value): return .some(transform(value))
        }
    }
}

// MARK: - Helpers

extension LodableContentState {
    public var some: Value? {
        guard case let .some(value) = self else { return nil }
        return value
    }

    public var inProgress: Bool {
        switch self {
        case .loading, .initial:
            return true
        case .error, .some:
            return false
        }
    }
}
