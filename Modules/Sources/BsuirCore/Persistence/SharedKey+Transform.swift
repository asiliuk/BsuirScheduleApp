import Foundation
import ComposableArchitecture

extension SharedKey {
    public typealias Map<NewValue> = _SharedKeyMap<Self, NewValue>
}

public struct _SharedKeyMap<Base: SharedKey, Value>: SharedKey {
    let base: Base
    let fromBaseValue: @Sendable (Base.Value) -> Value?
    let toBaseValue: @Sendable (Value) -> Base.Value?

    public init(
        base: Base,
        fromBaseValue: @Sendable @escaping (Base.Value) -> Value?,
        toBaseValue: @Sendable @escaping (Value) -> Base.Value?
    ) {
        self.base = base
        self.fromBaseValue = fromBaseValue
        self.toBaseValue = toBaseValue
    }

    public var id: Base.ID {
        self.base.id
    }

    public func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
        base.load(
            context: context.map(toBaseValue),
            continuation: LoadContinuation { baseResult in
                let result = baseResult.map { $0.flatMap(fromBaseValue) }
                continuation.resume(with: result)
            }
        )
    }

    public func save(_ value: Value, context: SaveContext, continuation: SaveContinuation) {
        guard let baseValue = toBaseValue(value) else {
            assertionFailure()
            return
        }
        base.save(
            baseValue,
            context: context,
            continuation: continuation
        )
    }

    public func subscribe(
      context: LoadContext<Value>, subscriber: SharedSubscriber<Value>
    ) -> SharedSubscription {
        base.subscribe(
            context: context.map(toBaseValue),
            subscriber: SharedSubscriber<Base.Value>(
                callback: { baseResult in
                    let result = baseResult.map { $0.flatMap(fromBaseValue) }
                    subscriber.yield(with: result)
                },
                onLoading: {
                    subscriber.yieldLoading($0)
                }
            )
        )
    }
}

private extension LoadContext {
    func map<U>(_ transform: (Value) -> U?) -> LoadContext<U> {
        guard
            case .initialValue(let value) = self,
            let newValue = transform(value)
        else { return .userInitiated }
        return .initialValue(newValue)
    }
}

extension SharedKey where Value == [String: Any] {
    public func coding<U>(_ coding: U.Type = U.self) -> Self.Map<U> where U: Sendable, U: Codable {
        _SharedKeyMap(
            base: self,
            fromBaseValue: { baseValue in
                do {
                    let data = try JSONSerialization.data(withJSONObject: baseValue, options: .fragmentsAllowed)
                    return try JSONDecoder().decode(U.self, from: data)
                } catch {
                    assertionFailure(error.localizedDescription)
                    return nil
                }
            },
            toBaseValue: { value in
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
