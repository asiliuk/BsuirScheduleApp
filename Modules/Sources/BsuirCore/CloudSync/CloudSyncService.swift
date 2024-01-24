import Foundation
import Combine
import Dependencies

public protocol CloudSyncService: AnyObject {
    func load()
    func observeChanges(forKey key: String, update: @escaping (Any?) -> Void) -> AnyCancellable
    subscript(key: String) -> Any? { get set }
}

extension DependencyValues {
    public var cloudSyncService: any CloudSyncService {
        get { self[CloudSyncServiceKey.self] }
        set { self[CloudSyncServiceKey.self] = newValue }
    }
}

private enum CloudSyncServiceKey: DependencyKey {
    static let liveValue: any CloudSyncService = LiveCloudSyncService()
    static let previewValue: any CloudSyncService = CloudSyncServiceMock()
    static let testValue: any CloudSyncService = CloudSyncServiceMock()
}
