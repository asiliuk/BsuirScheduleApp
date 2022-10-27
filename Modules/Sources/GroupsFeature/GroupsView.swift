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
            WithViewStore(
                store.scope(state: \.sections, action: { .loadableGroups($0) })
            ) { loadingViewStore in
                ZStack {
                    switch loadingViewStore.state {
                    case .initial, .loading:
                        LoadingStateView()
                    case .error:
                        ErrorStateView(retry: { loadingViewStore.send(.reload) })
                    case let .some(value):
                        GroupsContentView(
                            searchQuery: viewStore.binding(\.$searchQuery),
                            favorites: viewStore.favorites,
                            sections: value,
                            select: { viewStore.send(.groupTapped($0)) },
                            refresh: { await loadingViewStore.send(.refresh).finish() }
                        )
                    }
                }
                .task { await loadingViewStore.send(.task).finish() }
            }
            .navigation(item: viewStore.binding(\.$selectedGroup)) { group in
                // TODO: Handle navigation to shcedule screen
                Text("Selected \(group.name), id: \(group.id)")
                    .navigationTitle(group.name)
            }
            .navigationTitle("screen.groups.navigation.title")
            .task { await viewStore.send(.task).finish() }
            .task(id: viewStore.searchQuery) {
                do {
                    try await Task.sleep(nanoseconds: 200_000_000)
                    await viewStore.send(.filterGroups, animation: .default).finish()
                } catch {}
            }
        }
    }
}
