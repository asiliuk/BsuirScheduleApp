import Foundation
import Combine

public struct PersistedValue<Value> {
    public var value: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }

    public init(
        get: @escaping () -> Value,
        set: @escaping (Value) -> Void
    ) {
        self.get = get
        self.set = set
    }

    private let get: () -> Value
    private let set: (Value) -> Void
}

// MARK: - Operators

extension PersistedValue {
    public func map<U>(
        get: @escaping (Value) -> U,
        set: @escaping (U) -> Value
    ) -> PersistedValue<U> {
        PersistedValue<U>(
            get: { get(self.get()) },
            set: { self.set(set($0)) }
        )
    }

    public func withPublisher() -> (persisted: PersistedValue, publisher:  AnyPublisher<Value, Never>) {
        let subject = CurrentValueSubject<Value, Never>(get())
        return (
            persisted: PersistedValue(get: get, set: { subject.send($0); self.set($0) }),
            publisher: subject.eraseToAnyPublisher()
        )
    }

    public func unwrap<Wrapped>(withDefault default: Wrapped) -> PersistedValue<Wrapped> where Value == Wrapped? {
        map(get: { $0 ?? `default` }, set: { $0 })
    }
}
