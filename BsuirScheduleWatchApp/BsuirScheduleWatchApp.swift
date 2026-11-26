import SwiftUI
import ComposableArchitecture
import BsuirCore
import Dependencies
import WatchKit
import BsuirUI
import Kingfisher
import Favorites

@main
struct BsuirScheduleWatchApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: WatchAppDelegate

    var body: some Scene {
        WindowGroup {
            RootView(store: appDelegate.store)
        }
    }
}


final class WatchAppDelegate: NSObject, WKApplicationDelegate {
    private(set) lazy var store = Store(initialState: RootFeature.State()) {
        RootFeature()
    } withDependencies: {
        $0.imageCache = .default
        $0.defaultAppStorage = .asiliukShared
        $0.userDefaultsWatchSync = .live(defaults: $0.defaultAppStorage, keys: StorageKeys.watchSyncKeys)
    }

    override init() {
        super.init()

        // Make sure services are loaded with proper default storage
        // because products service updates premium flag in storage
        withDependencies {
            $0.defaultAppStorage = .asiliukShared
        } operation: {
            @Dependency(\.productsService) var productsService
            productsService.load()

            @Dependency(\.cloudSyncService) var cloudSyncService
            cloudSyncService.load()

            @Dependency(\.userDefaultsWatchSync) var userDefaultsWatchSync
            userDefaultsWatchSync.start()
        }
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        @Dependency(\.userDefaultsWatchSync) var userDefaultsWatchSync
        userDefaultsWatchSync.handle(backgroundTasks)
    }
}

private extension StorageKeys {
    static var watchSyncKeys: Set<String> {
        let favoritesKeys = [
           pinnedScheduleKey,
           favoriteGroupNamesKey,
           favoriteLecturerIDsKey,
           freeLoveHighScoreKey,
        ]

        let pairUIKeys = [pairFormAlwaysShowIconKey] + pairViewFormColorKeys

        return Set(favoritesKeys + pairUIKeys)
    }
}

