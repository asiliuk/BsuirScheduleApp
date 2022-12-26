import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture

public struct LecturersView: View {
    public let store: StoreOf<LecturersFeature>
    
    public init(store: StoreOf<LecturersFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LoadingLecturersView(
                viewStore: viewStore,
                store: store
            )
            .navigation(item: viewStore.binding(\.$lectorSchedule)) { _ in
                IfLetStore(
                    store
                        .scope(state: \.lectorSchedule, reducerAction: { .lectorSchedule($0) })
                        .returningLastNonNilState()
                ) { store in
                    LectorScheduleView(store: store)
                }
            }
            .navigationTitle("screen.lecturers.navigation.title")
            .task { await viewStore.send(.task).finish() }
        }
    }
}

private struct LoadingLecturersView: View {
    let viewStore: ViewStoreOf<LecturersFeature>
    let store: StoreOf<LecturersFeature>
    
    var body: some View {
        LoadingStore(
            store,
            state: \.$lecturers,
            loading: \.$loadedLecturers
        ) { store in
            WithViewStore(store) { lecturersViewStore in
                LecturersContentView(
                    pinned: viewStore.pinned,
                    favorites: viewStore.favorites,
                    lecturers: lecturersViewStore.state,
                    select: { viewStore.send(.lecturerTapped($0)) },
                    isOnTop: viewStore.binding(\.$isOnTop)
                )
                .refreshable { await lecturersViewStore.send(.refresh).finish() }
                .lecturersSearchable(store: self.store.scope(state: \.search, reducerAction: { .search($0) }))
            }
        } loading: {
            LecturersPlaceholderView(numberOfFavorites: viewStore.favoriteIds.count)
        } error: { store in
            LoadingErrorView(store: store)
        }
    }
}
