import SwiftUI
import ComposableArchitecture
import LoadableFeature
import EntityScheduleFeature

public struct GroupsFeatureViewV2: View {
    @Perception.Bindable var store: StoreOf<GroupsFeatureV2>

    public init(store: StoreOf<GroupsFeatureV2>) {
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
            .task { store.send(.task) }
        }
    }
}

private struct GroupsFeatureLoadingPlaceholderView: View {
    let store: StoreOf<GroupsFeatureV2>

    var body: some View {
        WithPerceptionTracking {
            GroupsPlaceholderView(
                hasPinned: store.hasPinnedPlaceholder,
                numberOfFavorites: store.favoritesPlaceholderCount
            )
        }
    }
}

