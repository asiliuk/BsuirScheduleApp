import SwiftUI
import ComposableArchitecture
import LoadableFeature
import EntityScheduleFeature
import BsuirUI

public struct GroupsFeatureView: View {
    @Bindable var store: StoreOf<GroupsFeature>
    @State var columnVisibility: NavigationSplitViewVisibility = .all

    public init(store: StoreOf<GroupsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("screen.groups.add.title", systemImage: "plus") {
                        store.send(.forceAddGroupButtonTapped)
                    }
                }
            }
            .navigationTitle("screen.groups.navigation.title")
        } detail: {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                if let store = store.scope(state: \.selectedGroup, action: \.selectedGroup) {
                    GroupScheduleView(store: store)
                } else {
                    Text("screen.groups.select_something.title")
                }
            } destination: { store in
                EntityScheduleFeatureViewV2(store: store)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .task { await store.send(.task).finish() }
        .forceAddAlert(store: $store.scope(state: \.forceAddAlert, action: \.forceAddAlert))
        .ignoresSafeArea(.container, edges: .top)
    }
}

private extension View {
    @MainActor 
    func forceAddAlert(store: Binding<StoreOf<ForceAddAlert>?>) -> some View {
        alert(
            store,
            title: { _ in "alert.forceAddGroup.title" },
            actions: { store in
                @Bindable var store = store
                TextField("alert.forceAddGroup.groupName.title", text: $store.groupName)
                    .keyboardType(.numberPad)

                Button("alert.forceAddGroup.button.add") {
                    store.send(.addButtonTapped)
                }

                Button("alert.forceAddGroup.button.cancel", role: .cancel) {
                    store.send(.cancelButtonTapped)
                }
            },
            message: { _ in
                Text("alert.forceAddGroup.groupName.message")
            }
        )
    }
}

private struct GroupsFeatureLoadingPlaceholderView: View {
    let store: StoreOf<GroupsFeature>

    var body: some View {
        GroupsPlaceholderView(
            hasPinned: store.hasPinnedPlaceholder,
            numberOfFavorites: store.favoritesPlaceholderCount
        )
    }
}
