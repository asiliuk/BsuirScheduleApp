import Foundation
import Combine
final class CloudSyncServiceMock: CloudSyncService {
    func load() {}

    func observeChanges(forKey key: String, update: @escaping (Any?) -> Void) -> AnyCancellable {
        AnyCancellable {}
    }
    
    subscript(key: String) -> Any? {
        get { nil }
        set {}
    }
}
