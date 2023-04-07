import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture
import SwiftUINavigation

public struct LecturersFeatureView: View {
    public let store: StoreOf<LecturersFeature>
    
    public init(store: StoreOf<LecturersFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.isOnTop) { viewStore in
            LoadingLecturersView(
                store: store,
                isOnTop: viewStore.binding(send: { .setIsOnTop($0) })
            )
            .navigationDestination(
                store: store.scope(state: \.$lectorSchedule, action: { .lectorSchedule($0) }),
                destination: LectorScheduleView.init
            )
            .navigationTitle("screen.lecturers.navigation.title")
            .task { await viewStore.send(.task).finish() }
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

                IfLetStore(self.store.scope(state: \.favorites)) { store in
                    Section("screen.lecturers.favorites.section.header") {
                        ForEachStore(
                            store.scope(
                                state: { $0 },
                                action: LecturersFeature.Action.favorite
                            )
                        ) { store in
                            LecturersRowView(store: store)
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
            .refreshable { await ViewStore(store.stateless).send(.refresh).finish() }
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
            self.numberOfFavorites = state.favoriteIds.count
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
