import Foundation
#if os(watchOS)
import WatchKit
#endif

final class UserDefaultsWatchSyncServiceMock: UserDefaultsWatchSyncService {
    func start() {}
    #if os(watchOS)
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {}
    #endif
}
