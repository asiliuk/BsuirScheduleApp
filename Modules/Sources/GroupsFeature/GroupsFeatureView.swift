import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture
import SwiftUINavigation

public struct GroupsFeatureView: View {
    public let store: StoreOf<GroupsFeature>
    
    public init(store: StoreOf<GroupsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.isOnTop) { viewStore in
            LoadingGroupsView(
                store: store,
                isOnTop: viewStore.binding(send: { .setIsOnTop($0) })
            )
            .navigationDestination(
                store: store.scope(state: \.$groupSchedule, action: { .groupSchedule($0) }),
                destination: GroupScheduleView.init
            )
            .navigationTitle("screen.groups.navigation.title")
            .task { await viewStore.send(.task).finish() }
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
            self.hasPinned = state.pinned != nil
            self.numberOfFavorites = state.favorites?.groupRows.count ?? 0
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
