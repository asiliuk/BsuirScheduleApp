import SwiftUI
import ComposableArchitecture
import BsuirCore
import Dependencies
import WatchKit

@main
struct BsuirScheduleWatchApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: WatchAppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(store: appDelegate.store)
        }
    }
}


final class WatchAppDelegate: NSObject, WKApplicationDelegate {
    private(set) lazy var store = Store(initialState: ContentFeature.State()) {
        ContentFeature()
    } withDependencies: {
        $0.defaultAppStorage = .asiliukShared
    }

    override init() {
        super.init()

        // Make sure services are loaded with proper default storage
        // because products service updates premium flag in storage
        withDependencies {
            $0.defaultAppStorage = .asiliukShared
        } operation: {
            @Dependency(\.cloudSyncService) var cloudSyncService
            cloudSyncService.load()
        }
    }
}
