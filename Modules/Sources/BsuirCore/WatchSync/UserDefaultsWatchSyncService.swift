import Foundation
import Dependencies
#if os(watchOS)
import WatchKit
#endif

public protocol UserDefaultsWatchSyncService {
    func start()
    #if os(watchOS)
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>)
    #endif
}

extension DependencyValues {
    public var userDefaultsWatchSync: any UserDefaultsWatchSyncService {
        get { self[UserDefaultsWatchSyncServiceKey.self] }
        set { self[UserDefaultsWatchSyncServiceKey.self] = newValue }
    }
}

public enum UserDefaultsWatchSyncServiceKey: TestDependencyKey {
    public static let testValue: any UserDefaultsWatchSyncService = UserDefaultsWatchSyncServiceMock()
}
