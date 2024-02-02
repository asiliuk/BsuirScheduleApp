import SwiftUI
import ReachabilityFeature
import ComposableArchitecture

struct NetworkAndDataFeatureView: View {
    @Perception.Bindable var store: StoreOf<NetworkAndDataFeature>

    var body: some View {
        List {
            Section("screen.settings.networkAndData.reachability.section.header") {
                ReachabilitySectionView(store: store)
            }

            Section("screen.settings.networkAndData.data.section.header") {
                Button("screen.settings.networkAndData.data.section.clearCache.button") {
                    store.send(.clearCacheTapped)
                }

                Button("screen.settings.networkAndData.data.section.clearWhatsNew.button") {
                    store.send(.clearWhatsNewTapped)
                }
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
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
                action: \.iisReachability
            )
        )

        ReachabilityView(
            store: store.scope(
                state: \.appleReachability,
                action: \.appleReachability
            )
        )
    }
}
