import SwiftUI
import BsuirCore
import BsuirApi
import BsuirUI
import Favorites
import ComposableArchitecture

@main
struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView(store: appDelegate.store)
                .onAppear { ViewStore(appDelegate.store).send(.onAppear) }
                .environment(\.reviewRequestService, appDelegate.reviewRequestService)
                .environmentObject(appDelegate.pairFormColorService)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private(set) lazy var store = Store(
        initialState: .init(),
        reducer: AppFeature()
            .dependency(\.urlCache, requestManager.cache)
            .dependency(\.imageCache, .default)
            .dependency(\.reviewRequestService, reviewRequestService)
            .dependency(\.pairFormColorService, pairFormColorService)
    )

    override init() {
        super.init()
    }

    private let storage: UserDefaults = .standard
    private let sharedStorage: UserDefaults = .asiliukShared
    private let requestManager = RequestsManager.iisBsuir()
    private(set) lazy var reviewRequestService = ReviewRequestService(storage: storage)
    private(set) lazy var pairFormColorService = PairFormColorService(storage: sharedStorage)
}
