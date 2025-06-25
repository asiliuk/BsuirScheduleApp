import Foundation
import ComposableArchitecture

extension SharedReaderKey {
    public static func cloudSyncable<Value>(
        key: String,
        cloudKey: String,
        shouldSyncInitialLocalValue: Bool = false,
        isEqual: @Sendable @escaping (Value?, Value?) -> Bool
    ) -> Self
    where Self == CloudSyncableSharedKey<Value> {
        CloudSyncableSharedKey(
            key: key,
            cloudKey: cloudKey,
            shouldSyncInitialLocalValue: shouldSyncInitialLocalValue,
            isEqual: isEqual
        )
    }

    public static func cloudSyncable<Value: Equatable>(
        key: String,
        cloudKey: String,
        shouldSyncInitialLocalValue: Bool = false
    ) -> Self
    where Self == CloudSyncableSharedKey<Value> {
        cloudSyncable(
            key: key,
            cloudKey: cloudKey,
            shouldSyncInitialLocalValue: shouldSyncInitialLocalValue,
            isEqual: ==
        )
    }
}

public struct CloudSyncableSharedKey<Value>: SharedKey {
    private let key: String
    private let cloudKey: String
    private let shouldSyncInitialLocalValue: Bool
    private let isEqual: @Sendable (Value?, Value?) -> Bool

    @UncheckedSendable private var userDefaults: UserDefaults
    private let cloudSyncService: any CloudSyncService

    init(
        key: String,
        cloudKey: String,
        shouldSyncInitialLocalValue: Bool,
        isEqual: @escaping @Sendable (Value?, Value?) -> Bool
    ) {
        @Dependency(\.defaultAppStorage) var store
        @Dependency(\.cloudSyncService) var cloudSyncService
        self.key = key
        self.cloudKey = cloudKey
        self.shouldSyncInitialLocalValue = shouldSyncInitialLocalValue
        self.isEqual = isEqual
        self._userDefaults = UncheckedSendable(store)
        self.cloudSyncService = cloudSyncService

        syncInitialValues()
    }

    public var id: String { key + cloudKey }

    public func save(_ value: Value, context: SaveContext, continuation: SaveContinuation) {
        cloudSyncService[cloudKey] = value
        userDefaults.set(value, forKey: key)
        continuation.resume()
    }

    public func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
        if let cloudValue = cloudSyncService[cloudKey], let value = cloudValue as? Value {
            continuation.resume(returning: value)
        } else if let localValue = userDefaults.object(forKey: key), let value = localValue as? Value {
            continuation.resume(returning: value)
        } else {
            continuation.resumeReturningInitialValue()
        }
    }

    public func subscribe(context: LoadContext<Value>, subscriber: SharedSubscriber<Value>) -> SharedSubscription {
        let previousValue = LockIsolated(context.initialValue)

        let cloudDidChange = cloudSyncService.observeChanges(forKey: cloudKey) { value in
            let newValue = value as? Value
            guard !isEqual(newValue, previousValue.value) || isEqual(newValue, context.initialValue) else { return }

            previousValue.withValue { $0 = newValue }
            
            // Update local value
            updateWithCloudValue(value)

            if let newValue {
                subscriber.yield(newValue)
            } else {
                subscriber.yieldReturningInitialValue()
            }
        }

        let userDefaultsDidChange = userDefaults.bsuirObserve(forKeyPath: key) { value in
            let newValue = value as? Value
            guard !isEqual(newValue, previousValue.value) || isEqual(newValue, context.initialValue) else { return }

            previousValue.withValue { $0 = newValue }

            // Update cloud value
            updateWithLocalValue(newValue)

            if let newValue {
                subscriber.yield(newValue)
            } else {
                subscriber.yieldReturningInitialValue()
            }
        }

        return SharedSubscription {
            cloudDidChange.cancel()
            userDefaultsDidChange.cancel()
        }
    }

    private func syncInitialValues() {
        if let cloudValue = cloudSyncService[cloudKey] {
            // Update persisted value with most recent cloud value
            updateWithCloudValue(cloudValue)
        } else if shouldSyncInitialLocalValue {
            let valueSyncedKey = "\(cloudKey)-was-synced"
            if
                !userDefaults.bool(forKey: valueSyncedKey),
                let value = userDefaults.object(forKey: key),
                let cloudSyncableValue = value as? CloudSyncabelValue
            {
                // Set initial cloud value if it was empty
                cloudSyncService[cloudKey] = cloudSyncableValue.value
                userDefaults.set(true, forKey: valueSyncedKey)
            }
        }
    }

    private func updateWithCloudValue(_ value: Any?) {
        guard let typedValue = value as? Value else {
            assertionFailure("Failed to cast value type. Got \(type(of: value)) but expected \(Value.self)")
            return
        }

        guard !isEqual(typedValue, userDefaults.object(forKey: key) as? Value) else {
            return
        }

        userDefaults.set(typedValue, forKey: key)
    }

    private func updateWithLocalValue(_ value: Value?) {
        guard !isEqual(value, cloudSyncService[cloudKey] as? Value) else {
            return
        }

        cloudSyncService[cloudKey] = value
    }
}
