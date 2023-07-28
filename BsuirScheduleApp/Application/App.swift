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
                .task { await ViewStore(appDelegate.store.stateless).send(.task).finish() }
                .environmentObject(appDelegate.pairFormColorService)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private(set) lazy var store = Store(
        initialState: .init(),
        reducer: AppFeature()
            .dependency(\.imageCache, .default)
            .dependency(\.pairFormColorService, pairFormColorService)
    )

    override init() {
        super.init()
    }

    private(set) lazy var pairFormColorService = PairFormColorService(
        storage: .asiliukShared,
        widgetService: .liveValue
    )
}
