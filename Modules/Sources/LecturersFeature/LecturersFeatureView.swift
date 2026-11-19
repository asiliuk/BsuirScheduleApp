import SwiftUI
import ComposableArchitecture
import EntityScheduleFeature
import LoadableFeature

public struct LecturersFeatureView: View {
    @Bindable var store: StoreOf<LecturersFeature>

    public init(store: StoreOf<LecturersFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            LoadingView(
                store: store.scope(state: \.lecturers, action: \.lecturers),
                inProgress: {
                    LecturersPlaceholderView(
                        hasPinned: store.hasPinnedPlaceholder,
                        numberOfFavorites: store.favoritesPlaceholderCount
                    )
                },
                failed: { store, _ in
                    LoadingErrorView(store: store)
                },
                loaded: { store, refresh in
                    LoadedLecturersFeatureView(
                        store: store,
                        refresh: refresh
                    )
                }
            )
            .navigationTitle("screen.lecturers.navigation.title")
        } detail: {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                if let store = store.scope(\.selectedLector, action: \.selectedLector) {
                    LectorScheduleView(store: store)
                } else {
                    Text("screen.lecturers.select_something.title")
                }
            } destination: { store in
                EntityScheduleFeatureViewV2(store: store)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}
