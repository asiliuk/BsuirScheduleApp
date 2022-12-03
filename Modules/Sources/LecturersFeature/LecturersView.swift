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
                        .scope(state: \.lectorSchedule, action: { .lectorSchedule($0) })
                        .returningLastNonNilState()
                ) { store in
                    LectorScheduleView(store: store)
                }
            }
            .navigationTitle("screen.lecturers.navigation.title")
            .task { await viewStore.send(.task).finish() }
            .task(id: viewStore.searchQuery) {
                do {
                    try await Task.sleep(nanoseconds: 300_000_000)
                    await viewStore.send(.filterLecturers, animation: .default).finish()
                } catch {}
            }
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
                    favorites: viewStore.favorites,
                    lecturers: lecturersViewStore.state,
                    select: { viewStore.send(.lecturerTapped($0)) },
                    dismissSearch: viewStore.dismissSearch
                )
                .refreshable { await lecturersViewStore.send(.refresh).finish() }
                .searchable(
                    text: viewStore.binding(\.$searchQuery),
                    prompt: Text("screen.lecturers.search.placeholder")
                )
                .scrollableToTop(isOnTop: viewStore.binding(\.$isOnTop))
            }
        } loading: {
            LoadingStateView()
        } error: { store in
            LoadingErrorView(store: store)
        }
    }
}
