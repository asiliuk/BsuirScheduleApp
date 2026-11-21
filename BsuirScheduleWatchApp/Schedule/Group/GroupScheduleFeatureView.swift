import SwiftUI
import ComposableArchitecture
import LoadableFeature

struct GroupScheduleFeatureView: View {
    let store: StoreOf<GroupScheduleFeature>

    var body: some View {
        LoadingView(
            store: store.scope(\.schedule, action: \.schedule),
            inProgress: {
                ProgressView()
            },
            failed: { store, _ in
                LoadingErrorView(store: store)
            },
            loaded: { store, refresh in
                LoadedScheduleFeatureView(
                    store: store,
                    refresh: refresh
                )
            }
        )
        .navigationTitle(store.name)
    }
}
