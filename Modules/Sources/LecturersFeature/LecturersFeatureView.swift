import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture

public struct LecturersFeatureView: View {
    public let store: StoreOf<LecturersFeature>
    
    public init(store: StoreOf<LecturersFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(store, observe: \.isOnTop) { viewStore in
                LoadingLecturersView(
                    store: store,
                    isOnTop: viewStore.binding(send: { .setIsOnTop($0) })
                )
                .navigationTitle("screen.lecturers.navigation.title")
                .navigationBarTitleDisplayMode(.inline)
                .task { await viewStore.send(.task).finish() }
            }
        } destination: { state in
            EntityScheduleView(state: state)
        }
    }
}

private struct LoadingLecturersView: View {
    let store: StoreOf<LecturersFeature>
    @Binding var isOnTop: Bool

    var body: some View {
        LoadingStore(
            store,
            state: \.$lecturers,
            loading: \.$loadedLecturers,
            action: LecturersFeature.Action.lector
        ) { store in
            ScrollableToTopList(isOnTop: $isOnTop) {
                IfLetStore(
                    self.store.scope(
                        state: \.pinned,
                        action: { .pinned($0) }
                    )
                ) { store in
                    Section("screen.lecturers.pinned.section.header") {
                        LecturersRowView(store: store)
                    }
                }

                WithViewStore(self.store, observe: { $0.favorites.isEmpty }) { viewStore in
                    // show only if have some favorites
                    if !viewStore.state {
                        Section("screen.lecturers.favorites.section.header") {
                            ForEachStore(
                                self.store.scope(
                                    state: \.favorites,
                                    action: LecturersFeature.Action.favorite
                                )
                            ) { store in
                                LecturersRowView(store: store)
                            }
                        }
                    }
                }

                Section {
                    ForEachStore(store.loaded()) { store in
                        LecturersRowView(store: store)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await store.send(.refresh).finish() }
            .overlay {
                if #available(iOS 17, *) {
                    WithViewStore(store.loaded(), observe: \.isEmpty) { viewStore in
                        if viewStore.state {
                            ContentUnavailableView.search
                        }
                    }
                }
            }
            .lecturersSearchable(store: self.store.scope(state: \.search, action: { .search($0) }))
        } loading: {
            LecturersLoadingPlaceholder(store: store)
        } error: { store in
            LoadingErrorView(store: store)
        }
    }
}

private struct LecturersLoadingPlaceholder: View {
    let store: StoreOf<LecturersFeature>

    struct ViewState: Equatable {
        let hasPinned: Bool
        let numberOfFavorites: Int

        init(state: LecturersFeature.State) {
            self.hasPinned = state.pinned != nil
            self.numberOfFavorites = state.favoritesPlaceholderCount
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            LecturersPlaceholderView(
                hasPinned: viewStore.hasPinned,
                numberOfFavorites: viewStore.numberOfFavorites
            )
        }
    }
}
