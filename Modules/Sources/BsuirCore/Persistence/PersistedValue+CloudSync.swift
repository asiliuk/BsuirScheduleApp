import Foundation
import Combine

extension PersistedValue {
    public func sync(with cloudSyncService: any CloudSyncService, forKey key: String) -> PersistedValue {
        syncInitialValues(with: cloudSyncService, forKey: key)
        let cancellable = cloudSyncService.observeChanges(forKey: key, update: updateWithCloudValue)

        return self.map(
            fromValue: { value in
                // Keep cancellable alive for same time as new persisted value
                _ = cancellable
                return (cloudSyncService[key] as? Value) ?? value
            },
            toValue: { newValue in
                cloudSyncService[key] = newValue
                return newValue
            }
        )
    }

    private func syncInitialValues(with cloudSyncService: any CloudSyncService, forKey key: String) {
        if let cloudValue = cloudSyncService[key] {
            // Update persisted value with most recent cloud value
            updateWithCloudValue(cloudValue)
        } else {
            // Set initial cloud value if it was empty
            cloudSyncService[key] = value
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
