import SwiftUI
import ComposableArchitecture
import LoadableFeature
import BsuirApi

struct GroupsFeatureView: View {
    let store: StoreOf<GroupsFeature>

    var body: some View {
        NavigationStack {
            LoadingView(store: store.scope(\.groups, action: \.groups)) {
                ProgressView()
            } failed: { store, _ in
                LoadingErrorView(store: store)
            } loaded: { store, refresh in
                LoadedGroupsView(store: store, refresh: refresh)
            }
        }
    }
}
