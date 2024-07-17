import Foundation
import ComposableArchitecture

public struct PersistenceKeyTransform<Base: PersistenceKey, Value>: PersistenceKey {
    let base: Base
    let fromValue: (Value) -> Base.Value?
    let toValue: (Base.Value) -> Value?

    public init(
        base: Base,
        fromValue: @escaping (Value) -> Base.Value?,
        toValue: @escaping (Base.Value) -> Value?
    ) {
        self.base = base
        self.fromValue = fromValue
        self.toValue = toValue
    }

    public var id: Base.ID {
        self.base.id
    }

    public func load(initialValue: Value?) -> Value? {
        self.base.load(initialValue: initialValue.flatMap(fromValue)).flatMap(toValue)
    }

    public func save(_ value: Value) {
        if let baseValue = fromValue(value) {
            self.base.save(baseValue)
        } else {
            assertionFailure()
        }
    }

    public func subscribe(
        initialValue: Value?,
        didSet: @Sendable @escaping (Value?) -> Void
    ) -> Shared<Value>.Subscription {
        let subscription = self.base.subscribe(initialValue: initialValue.flatMap(fromValue)) { baseValue in
            `didSet`(baseValue.flatMap(toValue))
        }
        return Shared<Value>.Subscription(subscription.cancel)
    }
}

extension PersistenceKeyTransform where Value: Codable, Base.Value == [String: Any] {
    public init(base: Base, coding: Value.Type = Value.self) {
        self.init(
            base: base,
            fromValue: { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    return jsonObject as? [String: Any]
                } catch {
                    assertionFailure(error.localizedDescription)
                    return nil
                }
            },
            toValue: { dictionary in
                do {
                    let data = try JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
                    return try JSONDecoder().decode(Value.self, from: data)
                } catch {
                    assertionFailure(error.localizedDescription)
                    return nil
                }
            }
        )
    }
}
