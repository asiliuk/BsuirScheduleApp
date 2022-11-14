import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import ComposableArchitecture

public struct GroupsView: View {
    public let store: StoreOf<GroupsFeature>
    
    public init(store: StoreOf<GroupsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LoadingGroupsView(viewStore: viewStore, store: store)
                .navigationTitle("screen.groups.navigation.title")
                .task { await viewStore.send(.task).finish() }
                .task(id: viewStore.searchQuery) {
                    do {
                        try await Task.sleep(nanoseconds: 200_000_000)
                        await viewStore.send(.filterGroups, animation: .default).finish()
                    } catch {}
                }
                .navigation(item: viewStore.binding(\.$selectedGroup)) { group in
                    // TODO: Handle navigation to shcedule screen
                    Text("Selected \(group.name), id: \(group.id)")
                        .navigationTitle(group.name)
                }
        }
    }
}

private struct LoadingGroupsView: View {
    let viewStore: ViewStoreOf<GroupsFeature>
    let store: StoreOf<GroupsFeature>
    
    var body: some View {
        LoadingStore(
            store,
            state: \.$sections,
            loading: \.$loadedGroups,
            action: GroupsFeature.Action.view
        ) { store in
            WithViewStore(store) { sectionsViewStore in
                GroupsContentView(
                    searchQuery: viewStore.binding(\.$searchQuery),
                    favorites: viewStore.favorites,
                    sections: sectionsViewStore.state,
                    select: { sectionsViewStore.send(.value(.groupTapped($0))) },
                    refresh: { await sectionsViewStore.send(.refresh).finish() }
                )
            }
        } loading: {
            LoadingStateView()
        } error: { store in
            WithViewStore(store) { viewStore in
                ErrorStateView(retry: { viewStore.send(.reload) })
            }
        }
    }
}
