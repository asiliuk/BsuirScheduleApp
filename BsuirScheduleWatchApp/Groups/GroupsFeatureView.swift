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
            } failed: { _, reload in
                Text("Something went wrong...")
            } loaded: { store, refresh in
                LoadedGroupsView(store: store, refresh: refresh)
            }
        }
    }
}
