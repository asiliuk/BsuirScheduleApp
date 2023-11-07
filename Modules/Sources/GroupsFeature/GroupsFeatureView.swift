import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture

public struct GroupsFeatureView: View {
    public let store: StoreOf<GroupsFeature>
    
    public init(store: StoreOf<GroupsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(store, observe: \.isOnTop) { viewStore in
                LoadingGroupsView(
                    store: store,
                    isOnTop: viewStore.binding(send: { .setIsOnTop($0) })
                )
                .navigationTitle("screen.groups.navigation.title")
                .navigationBarTitleDisplayMode(.inline)
                .task { await viewStore.send(.task).finish() }
            }
        } destination: { state in
            EntityScheduleView(state: state)
        }
    }
}

private struct LoadingGroupsView: View {
    let store: StoreOf<GroupsFeature>
    @Binding var isOnTop: Bool

    var body: some View {
        LoadingStore(
            store,
            state: \.$sections,
            loading: \.$loadedGroups,
            action: GroupsFeature.Action.groupSection
        ) { store in
            ScrollableToTopList(isOnTop: $isOnTop) {
                IfLetStore(self.store.scope(state: \.pinned, action: { .pinned($0) })) { store in
                    GroupsSectionView(store: store)
                }

                IfLetStore(self.store.scope(state: \.favorites, action: { .favorites($0) })) { store in
                    GroupsSectionView(store: store)
                }

                ForEachStore(store.loaded()) { store in
                    GroupsSectionView(store: store)
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await store.send(.refresh).finish() }
            .groupsSearchable(store: self.store.scope(state: \.search, action: { .search($0) }))
        } loading: {
            GroupsLoadingPlaceholder(store: store)
        } error: { store in
            LoadingErrorView(store: store)
        }
    }
}

private struct GroupsLoadingPlaceholder: View {
    let store: StoreOf<GroupsFeature>

    struct ViewState: Equatable {
        let hasPinned: Bool
        let numberOfFavorites: Int

        init(state: GroupsFeature.State) {
            self.hasPinned = state.hasPinnedPlaceholder
            self.numberOfFavorites = state.favoritesPlaceholderCount
        }
    }
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            GroupsPlaceholderView(
                hasPinned: viewStore.hasPinned,
                numberOfFavorites: viewStore.numberOfFavorites
            )
        }
    }
}
