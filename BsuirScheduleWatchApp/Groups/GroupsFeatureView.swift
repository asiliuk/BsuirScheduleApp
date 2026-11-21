import SwiftUI
import ComposableArchitecture
import LoadableFeature
import BsuirApi

struct GroupsFeatureView: View {
    @Bindable var store: StoreOf<GroupsFeature>

    var body: some View {
        NavigationStack(path: $store.scope(\.path, action: \.path)) {
            LoadingView(store: store.scope(\.groups, action: \.groups)) {
                ProgressView()
            } failed: { store, _ in
                LoadingErrorView(store: store)
            } loaded: { store, refresh in
                LoadedGroupsView(store: store, refresh: refresh)
            }
        } destination: { store in
            ScheduleFeatureView(store: store)
        }
    }
}
