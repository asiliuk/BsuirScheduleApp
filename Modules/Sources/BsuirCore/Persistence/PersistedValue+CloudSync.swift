import Foundation
import Combine
import Dependencies

extension PersistedValue where Value: CloudSyncabelValue {
    public func sync(
        with cloudSyncService: any CloudSyncService,
        forKey key: String,
        shouldSyncInitialLocalValue: Bool = false,
        userDefaults: UserDefaults = .asiliukShared
    ) -> PersistedValue {
        syncInitialValues(
            with: cloudSyncService,
            forKey: key,
            shouldSyncInitialLocalValue: shouldSyncInitialLocalValue,
            userDefaults: userDefaults
        )

        let cancellable = cloudSyncService.observeChanges(forKey: key, update: updateWithCloudValue)

        return self.map(
            fromValue: { value in
                // Keep cancellable alive for same time as new persisted value
                _ = cancellable
                guard 
                    let cloudValueRaw = cloudSyncService[key],
                    let cloudValue = cloudValueRaw as? Value
                else { return value }
                return cloudValue
            },
            toValue: { newValue in
                cloudSyncService[key] = newValue.value
                return newValue
            }
        )
    }

    private func syncInitialValues(
        with cloudSyncService: any CloudSyncService,
        forKey key: String,
        shouldSyncInitialLocalValue: Bool,
        userDefaults: UserDefaults
    ) {
        if let cloudValue = cloudSyncService[key] {
            // Update persisted value with most recent cloud value
            updateWithCloudValue(cloudValue)
        } else if shouldSyncInitialLocalValue {
            let valueSyncedKey = "\(key)-was-synced"
            if !userDefaults.bool(forKey: valueSyncedKey) {
                // Set initial cloud value if it was empty
                cloudSyncService[key] = value.value
                userDefaults.set(true, forKey: valueSyncedKey)
            }
        }
    }

    private func updateWithCloudValue(_ value: Any?) {
        guard let typedValue = value as? Value else {
            assertionFailure("Failed to cast value type. Got \(type(of: value)) but expected \(Value.self)")
            return
        }

        self.value = typedValue
    }
}

// MARK: - Syncable

public protocol CloudSyncabelValue {
    var value: Any? { get }
}

extension Int: CloudSyncabelValue {
    public var value: Any? { self }
}

extension String: CloudSyncabelValue {
    public var value: Any? { self }
}

extension Array: CloudSyncabelValue where Element: CloudSyncabelValue {
    public var value: Any? { self }
}

extension Dictionary<String, Any>: CloudSyncabelValue {
    public var value: Any? { self }
}

extension Optional: CloudSyncabelValue where Wrapped: CloudSyncabelValue {
    public var value: Any? {
        switch self {
        case .none:
            return nil
        case .some(let value):
            return value
        }
    }
}
