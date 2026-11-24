import SwiftUI
import ComposableArchitecture
import BsuirCore
import Dependencies
import WatchKit
import BsuirUI
import Kingfisher

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
        }
    }
}
