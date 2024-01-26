import Foundation
import Combine
final class CloudSyncServiceMock: CloudSyncService {
    private(set) var loadCallsCount: Int = 0
    func load() {
        loadCallsCount += 1
    }

    private(set) var observeChangesCalls: [String] = []
    private(set) var observeChangesUpdates: [(Any?) -> Void] = []
    func observeChanges(forKey key: String, update: @escaping (Any?) -> Void) -> AnyCancellable {
        observeChangesCalls.append(key)
        observeChangesUpdates.append(update)
        return AnyCancellable {}
    }
    
    private(set) var storage: [String: Any] = [:]
    subscript(key: String) -> Any? {
        get { storage[key] }
        set { storage[key] = newValue }
    }
}
