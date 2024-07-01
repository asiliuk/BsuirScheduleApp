import Foundation
import ComposableArchitecture

extension PersistenceReaderKey {
    public static func cloudSyncable<Value>(
        key: String,
        cloudKey: String,
        shouldSyncInitialLocalValue: Bool = false
    ) -> Self
    where Self == CloudSyncablePersistenceKey<Value> {
        CloudSyncablePersistenceKey(
            key: key,
            cloudKey: cloudKey,
            shouldSyncInitialLocalValue: shouldSyncInitialLocalValue
        )
    }
}

public struct CloudSyncablePersistenceKey<Value>: PersistenceKey {
    private let key: String
    private let cloudKey: String
    private let shouldSyncInitialLocalValue: Bool

    private let userDefaults: UserDefaults
    private let cloudSyncService: any CloudSyncService

    init(key: String, cloudKey: String, shouldSyncInitialLocalValue: Bool) {
        @Dependency(\.defaultAppStorage) var store
        @Dependency(\.cloudSyncService) var cloudSyncService
        self.key = key
        self.cloudKey = cloudKey
        self.shouldSyncInitialLocalValue = shouldSyncInitialLocalValue
        self.userDefaults = store
        self.cloudSyncService = cloudSyncService

        syncInitialValues()
    }

    public var id: String { key + cloudKey }

    public func save(_ value: Value) {
        cloudSyncService[cloudKey] = value
        userDefaults.set(value, forKey: key)
    }

    public func load(initialValue: Value?) -> Value? {
        if let cloudValue = cloudSyncService[cloudKey], let value = cloudValue as? Value {
            return value
        } else if let localValue = userDefaults.object(forKey: key), let value = localValue as? Value {
            return value
        } else {
            return initialValue
        }
    }

    public func subscribe(
        initialValue: Value?,
        didSet: @escaping (Value?) -> Void
    ) -> Shared<Value>.Subscription {
        let previousValue = LockIsolated(initialValue)

        let cloudDidChange = cloudSyncService.observeChanges(forKey: cloudKey) { value in
            let newValue = value as? Value
            defer { previousValue.withValue { $0 = newValue } }
            guard !(_isEqual(newValue as Any, previousValue.value as Any) ?? false)
                || (_isEqual(newValue as Any, initialValue as Any) ?? true),
                  !(_isEqual(newValue as Any, userDefaults.object(forKey: key) as Any) ?? false)
            else { return }
            updateWithCloudValue(value)
            `didSet`(newValue)
        }

        let userDefaultsDidChange = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: userDefaults,
            queue: nil
        ) { _ in
            let newValue = userDefaults.object(forKey: key) as? Value
            defer { previousValue.withValue { $0 = newValue } }
            guard !(_isEqual(newValue as Any, previousValue.value as Any) ?? false)
                || (_isEqual(newValue as Any, initialValue as Any) ?? true),
                  !(_isEqual(newValue as Any, cloudSyncService[cloudKey] as Any) ?? false)
            else { return }
            cloudSyncService[cloudKey] = newValue
            didSet(newValue)
        }

        return Shared.Subscription {
            cloudDidChange.cancel()
            NotificationCenter.default.removeObserver(userDefaultsDidChange)
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

        guard !(_isEqual(value as Any, userDefaults.object(forKey: key) as Any) ?? false) else {
            return
        }

        userDefaults.set(typedValue, forKey: key)
    }
}

// MARK: - Equatable

func _isEqual(_ lhs: Any, _ rhs: Any) -> Bool? {
    (lhs as? any Equatable)?.isEqual(other: rhs)
}

extension Equatable {
    fileprivate func isEqual(other: Any) -> Bool {
        self == other as? Self
    }
}
