import Foundation
import ComposableArchitecture

extension PersistenceReaderKey {
    public static func cloudSyncable<Value>(
        key: String,
        cloudKey: String,
        shouldSyncInitialLocalValue: Bool = false,
        isEqual: @escaping (Value?, Value?) -> Bool
    ) -> Self
    where Self == CloudSyncablePersistenceKey<Value> {
        CloudSyncablePersistenceKey(
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
    where Self == CloudSyncablePersistenceKey<Value> {
        cloudSyncable(
            key: key,
            cloudKey: cloudKey,
            shouldSyncInitialLocalValue: shouldSyncInitialLocalValue,
            isEqual: ==
        )
    }
}

public struct CloudSyncablePersistenceKey<Value>: PersistenceKey {
    private let key: String
    private let cloudKey: String
    private let shouldSyncInitialLocalValue: Bool
    private let isEqual: (Value?, Value?) -> Bool

    private let userDefaults: UserDefaults
    private let cloudSyncService: any CloudSyncService

    init(
        key: String,
        cloudKey: String,
        shouldSyncInitialLocalValue: Bool,
        isEqual: @escaping (Value?, Value?) -> Bool
    ) {
        @Dependency(\.defaultAppStorage) var store
        @Dependency(\.cloudSyncService) var cloudSyncService
        self.key = key
        self.cloudKey = cloudKey
        self.shouldSyncInitialLocalValue = shouldSyncInitialLocalValue
        self.isEqual = isEqual
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
            guard !isEqual(newValue, previousValue.value) || isEqual(newValue, initialValue) else { return }

            previousValue.withValue { $0 = newValue }

            // Update local value
            updateWithCloudValue(value)

            `didSet`(newValue)
        }

        let notificationCenter = NotificationCenter.default
        let userDefaultsDidChange = notificationCenter.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: userDefaults,
            queue: .main
        ) { _ in
            let newValue = userDefaults.object(forKey: key) as? Value
            guard !isEqual(newValue, previousValue.value) || isEqual(newValue, initialValue) else { return }

            previousValue.withValue { $0 = newValue }

            // Update cloud value
            updateWithLocalValue(newValue)

            `didSet`(newValue)
        }

        return Shared.Subscription {
            cloudDidChange.cancel()
            notificationCenter.removeObserver(userDefaultsDidChange)
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
