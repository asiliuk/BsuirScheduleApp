import SwiftUI
import ComposableArchitecture
import EntityScheduleFeature
import LoadableFeature

public struct LecturersFeatureView: View {
    @Perception.Bindable var store: StoreOf<LecturersFeature>

    public init(store: StoreOf<LecturersFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
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
                .navigationBarTitleDisplayMode(.inline)
            } destination: { store in
                EntityScheduleFeatureViewV2(store: store)
            }
            .onAppear { store.send(.onAppear) }
        }
    }
}
