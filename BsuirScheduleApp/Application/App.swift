import SwiftUI
import AppFeature
import BsuirCore
import BsuirApi
import BsuirUI
import ComposableArchitecture

@main
struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: appDelegate.store)
                .task { await appDelegate.store.send(.task).finish() }
                .environmentObject({ () -> PairFormColorService in
                    @Dependency(\.pairFormColorService) var pairFormColorService
                    return pairFormColorService
                }())
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private(set) lazy var store = Store(initialState: .init()) {
        AppFeature()
            .dependency(\.imageCache, .default)
    }

    override init() {
        super.init()
        #if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            UIView.setAnimationsEnabled(false)
            UIApplication.shared.keyWindow?.layer.speed = 100
        }
        #endif
    }
}

#if DEBUG
extension UIApplication {
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
