import Foundation
import Combine
import Collections

@propertyWrapper
public struct PersistedValue<Value> {
    public var value: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }

    public var wrappedValue: Value {
        get { value }
        nonmutating set { value = newValue }
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
    public static func constant(_ value: Value) -> Self {
        PersistedValue(get: { value }, set: { _ in })
    }

    public func map<U>(
        fromValue: @escaping (Value) -> U,
        toValue: @escaping (U) -> Value
    ) -> PersistedValue<U> {
        PersistedValue<U>(
            get: { fromValue(self.get()) },
            set: { self.set(toValue($0)) }
        )
    }

    public func withPublisher() -> (persisted: PersistedValue, publisher:  AnyPublisher<Value, Never>) {
        let subject = CurrentValueSubject<Value, Never>(get())
        return (
            persisted: onSet(subject.send),
            publisher: subject.eraseToAnyPublisher()
        )
    }

    public func unwrap<Wrapped>(withDefault default: Wrapped) -> PersistedValue<Wrapped> where Value == Wrapped? {
        map(fromValue: { $0 ?? `default` }, toValue: { .some($0) })
    }

    public func onSet(_ onSet: @escaping (Value) -> Void) -> PersistedValue {
        PersistedValue(get: get, set: { onSet($0); self.set($0) })
    }

    public func cacheInMemory() -> Self {
        var cache: Value?
        return .init(
            get: {
                if let cache { return cache }
                let value = get()
                cache = value
                return value
            },
            set: { newValue in
                set(newValue)
                cache = newValue
            }
        )
    }
}

// MARK: - OrderedSet

extension PersistedValue {
    public func toOrderedSet<Element: Hashable>() -> PersistedValue<OrderedSet<Element>?> where Value == [Element]? {
        map(
            fromValue: { $0.map(OrderedSet.init) },
            toValue: { $0.map(Array.init) }
        )
    }
}

// MARK: - Codable

extension PersistedValue where Value == Data? {
    public func codable<U: Codable>(_ value: U.Type = U.self) -> PersistedValue<U?> {
        map(
            fromValue: { $0.flatMap { try? JSONDecoder().decode(U.self, from: $0) } },
            toValue: { $0.flatMap { try? JSONEncoder().encode($0) } }
        )
    }
}

extension PersistedValue where Value == [String: Any]? {
    public func codable<U: Codable>(_ value: U.Type = U.self) -> PersistedValue<U?> {
        map(
            fromValue: { dictionary in
                guard let dictionary else { return nil }

                do {
                    let data = try JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
                    return try JSONDecoder().decode(U.self, from: data)
                } catch {
                    assertionFailure(error.localizedDescription)
                    return nil
                }
            },
            toValue: { value in
                guard let value else { return nil }

                do {
                    let data = try JSONEncoder().encode(value)
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    return jsonObject as? [String: Any]
                } catch {
                    assertionFailure(error.localizedDescription)
                    return nil
                }
            }
        )
    }
}
