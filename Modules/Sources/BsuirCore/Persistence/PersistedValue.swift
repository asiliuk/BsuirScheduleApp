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
        self.init(get: get, set: set, accessTracker: nil)
    }

    private init(
        get: @escaping () -> Value,
        set: @escaping (Value) -> Void,
        accessTracker: PersistedValueAccessTracker?
    ) {
        self.get = get
        if let accessTracker {
            // Assuming this is intermediate persisted value
            // No need to call `accessTracker` because it would be done at leaf component level
            // Otherwise we could end up calling it on each level of persisted value nesting
            self.accessTracker = accessTracker
            self.set = set
        } else {
            // Assuming we're in initial (leaf) persisted value
            // so we're creating first access tracker and notifying it when needed
            let newAccessTracker = PersistedValueAccessTracker()
            self.accessTracker = newAccessTracker
            self.set = { newValue in
                set(newValue)
                newAccessTracker.onDidSet()
            }
        }
    }

    private let get: () -> Value
    private let set: (Value) -> Void
    private let accessTracker: PersistedValueAccessTracker
}

private final class PersistedValueAccessTracker {
    var onDidSet: () -> Void = {}
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
        return PersistedValue<U>(
            get: { fromValue(self.get()) },
            set: { self.set(toValue($0)) },
            accessTracker: accessTracker
        )
    }

    public func withPublisher() -> (persisted: PersistedValue, publisher:  AnyPublisher<Value, Never>) {
        let subject = CurrentValueSubject<Value, Never>(get())
        return (
            persisted: onDidSet { subject.value = get() },
            publisher: subject.eraseToAnyPublisher()
        )
    }

    public func unwrap<Wrapped>(withDefault default: Wrapped) -> PersistedValue<Wrapped> where Value == Wrapped? {
        map(fromValue: { $0 ?? `default` }, toValue: { .some($0) })
    }

    public func onDidSet(_ onDidSet: @escaping () -> Void) -> PersistedValue {
        self.accessTracker.onDidSet = onDidSet
        return self
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
