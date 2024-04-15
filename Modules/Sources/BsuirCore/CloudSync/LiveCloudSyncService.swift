import Foundation
import Combine

final class LiveCloudSyncService {
    private let keyValueStore: NSUbiquitousKeyValueStore
    private let notificationCenter: NotificationCenter

    private var observers: [String: (Any?) -> Void] = [:]

    init(
        keyValueStore: NSUbiquitousKeyValueStore = .default,
        notificationCenter: NotificationCenter = .default
    ) {
        self.keyValueStore = keyValueStore
        self.notificationCenter = notificationCenter
    }
}

// MARK: - CloudSyncService

extension LiveCloudSyncService: CloudSyncService {
    func load() {
        notificationCenter.addObserver(
            self,
            selector: #selector(keyValueStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: keyValueStore
        )

        if keyValueStore.synchronize() == false {
            assertionFailure("This app was not built with the proper entitlement requests.")
            Logger.cloudSync.error("Load failed")
        } else {
            Logger.cloudSync.info("Load succeed")
        }
    }

    func observeChanges(forKey key: String, update: @escaping (Any?) -> Void) -> AnyCancellable {
        observers[key] = update
        return AnyCancellable { [weak self] in self?.observers[key] = nil }
    }

    subscript(key: String) -> Any? {
        get { keyValueStore.object(forKey: key) }
        set { keyValueStore.set(newValue, forKey: key) }
    }
}

// MARK: - Changes

private extension LiveCloudSyncService {
    @objc func keyValueStoreDidChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]
        else { return }

        Logger.cloudSync.info("Values did change for keys: \(keys)")

        for key in keys {
            let observer = observers[key]
            let value = self[key]
            DispatchQueue.main.async { observer?(value) }
        }
    }
}

import OSLog

private extension Logger {
    static let cloudSync = bsuirSchedule(category: "Cloud Sync")
}
