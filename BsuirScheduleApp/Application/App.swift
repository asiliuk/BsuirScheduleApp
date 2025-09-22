import SwiftUI
import AppFeature
import BsuirCore
import BsuirApi
import BsuirUI
import ComposableArchitecture
import Favorites

@main
struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            DebugAppView(appDelegate: appDelegate)
            #else
            AppView(store: appDelegate.store)
            #endif
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private(set) lazy var store = Store(initialState: .init()) {
        AppFeature()
    } withDependencies: { [isTestingEnabled] in
        $0.imageCache = .default
        $0.defaultAppStorage = .asiliukShared
        #if DEBUG
        if isTestingEnabled {
            $0.context = .preview
            $0.date.now = Date(timeIntervalSince1970: 1699830000)
            $0.defaultAppStorage.set(["151003", "151005"], forKey: StorageKeys.favoriteGroupNamesKey)
            $0.defaultAppStorage.set([504394, 500570], forKey: StorageKeys.favoriteLecturerIDsKey)
        }
        #endif
    }

    override init() {
        super.init()

        #if DEBUG
        if isTestingEnabled { disableAnimations() }
        #endif

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

private extension AppDelegate {
    var isTestingEnabled: Bool {
        CommandLine.arguments.contains("enable-testing")
    }
}

#if DEBUG
private struct DebugAppView: View {
    let appDelegate: AppDelegate

    var body: some View {
        WithPerceptionTracking {
            if appDelegate.isWidgetsPreviewEnabled {
                ScheduleWidgetPreviews()
            } else {
                AppView(store: appDelegate.store)
            }
        }
    }
}

private extension AppDelegate {
    var isWidgetsPreviewEnabled: Bool {
        CommandLine.arguments.contains("enable-widget-preview")
    }

    func disableAnimations() {
        UIView.setAnimationsEnabled(false)
        UIApplication.shared.keyWindow?.layer.speed = 100
    }
}

private extension UIApplication {
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
}
#endif
