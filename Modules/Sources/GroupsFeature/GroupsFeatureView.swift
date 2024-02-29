import SwiftUI
import ComposableArchitecture
import LoadableFeature
import EntityScheduleFeature

public struct GroupsFeatureView: View {
    @Perception.Bindable var store: StoreOf<GroupsFeature>

    public init(store: StoreOf<GroupsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                LoadingView(
                    store: store.scope(state: \.groups, action: \.groups),
                    inProgress: {
                        GroupsPlaceholderView(
                            hasPinned: store.hasPinnedPlaceholder,
                            numberOfFavorites: store.favoritesPlaceholderCount
                        )
                    },
                    failed: { store, _ in
                        LoadingErrorView(store: store)
                    },
                    loaded: { store, refresh in
                        LoadedGroupsFeatureView(
                            store: store,
                            refresh: refresh
                        )
                    }
                )
                .navigationTitle("screen.groups.navigation.title")
                .navigationBarTitleDisplayMode(.inline)
            } destination: { store in
                EntityScheduleFeatureViewV2(store: store)
            }
            .onAppear { store.send(.onAppear) }
            .task { await store.send(.task).finish() }
        }
    }
}

private struct GroupsFeatureLoadingPlaceholderView: View {
    let store: StoreOf<GroupsFeature>

    var body: some View {
        WithPerceptionTracking {
            GroupsPlaceholderView(
                hasPinned: store.hasPinnedPlaceholder,
                numberOfFavorites: store.favoritesPlaceholderCount
            )
        }
    }
}

