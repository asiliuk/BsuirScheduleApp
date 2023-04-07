import SwiftUI
import ReachabilityFeature
import ComposableArchitecture

struct NetworkAndDataFeatureView: View {
    let store: StoreOf<NetworkAndDataFeature>

    var body: some View {
        List {
            Section("screen.settings.networkAndData.reachability.section.header") {
                ReachabilitySectionView(store: store)
            }

            Section("screen.settings.networkAndData.data.section.header") {
                ClearCacheSectionView(store: store)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("screen.settings.networkAndData.navigation.title")
    }
}

// MARK: - Reachability

private struct ReachabilitySectionView: View {
    let store: StoreOf<NetworkAndDataFeature>

    var body: some View {
        ReachabilityView(
            store: store.scope(
                state: \.iisReachability,
                action: { .iisReachability($0) }
            )
        )

        ReachabilityView(
            store: store.scope(
                state: \.appleReachability,
                action: { .appleReachability($0) }
            )
        )
    }
}

// MARK: - Clear Cache Section

private struct ClearCacheSectionView: View {
    let store: StoreOf<NetworkAndDataFeature>

    var body: some View {
        Button("screen.settings.networkAndData.data.section.clearCache.button") {
            ViewStore(store.stateless).send(.clearCacheTapped)
        }
        .alert(store.scope(state: \.cacheClearedAlert), dismiss: .cacheClearedAlertDismissed)
    }
}
