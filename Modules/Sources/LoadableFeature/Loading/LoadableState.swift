import Foundation

@propertyWrapper
public enum LoadableState<Value> {
    case initial
    case loading
    case error
    case some(Value)
    
    public init(wrappedValue: Value? = nil) {
        if let wrappedValue {
            self = .some(wrappedValue)
        } else {
            self = .initial
        }
    }
    
    public var wrappedValue: Value? {
        get {
            guard case let .some(value) = self else { return nil }
            return value
        }
        set {
            guard let newValue else {
                assertionFailure()
                return self = .error
            }
            
            self = .some(newValue)
        }
    }
    
    public var projectedValue: Self {
      get { self }
      set { self = newValue }
    }
}

extension LoadableState: Equatable where Value: Equatable {}
extension LoadableState: Hashable where Value: Hashable {}
