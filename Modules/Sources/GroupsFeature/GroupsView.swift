import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture

public struct GroupsView: View {
    public let store: StoreOf<GroupsFeature>
    
    public init(store: StoreOf<GroupsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LoadingGroupsView(
                viewStore: viewStore,
                store: store
            )
            .navigationTitle("screen.groups.navigation.title")
            .task { await viewStore.send(.task).finish() }
            .task(id: viewStore.searchQuery) {
                do {
                    try await Task.sleep(nanoseconds: 200_000_000)
                    await viewStore.send(.filterGroups, animation: .default).finish()
                } catch {}
            }
            .navigation(item: viewStore.binding(\.$groupSchedule)) { _ in
                IfLetStore(
                    store
                        .scope(state: \.groupSchedule, action: { .groupSchedule($0) })
                        .returningLastNonNilState()
                ) { store in
                    GroupScheduleView(store: store)
                }
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
            loading: \.$loadedGroups
        ) { store in
            WithViewStore(store) { sectionsViewStore in
                GroupsContentView(
                    favorites: viewStore.favorites,
                    sections: sectionsViewStore.state,
                    select: { viewStore.send(.groupTapped(name: $0)) },
                    dismissSearch: viewStore.dismissSearch
                )
                .refreshable { await sectionsViewStore.send(.refresh).finish() }
                .searchable(
                    text: viewStore.binding(\.$searchQuery),
                    prompt: Text("screen.groups.search.placeholder")
                )
                .scrollableToTop(isOnTop: viewStore.binding(\.$isOnTop))
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
