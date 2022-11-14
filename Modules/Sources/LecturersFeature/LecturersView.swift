import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
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
            .navigation(item: viewStore.binding(\.$selectedLector)) { lecturer in
                // TODO: Handle navigation to shcedule screen
                Text("Selected \(lecturer.fio), id: \(lecturer.id)")
                    .navigationTitle(lecturer.fio)
            }
            .navigationTitle("screen.lecturers.navigation.title")
            .task { await viewStore.send(.task).finish() }
            .task(id: viewStore.searchQuery) {
                do {
                    try await Task.sleep(nanoseconds: 200_000_000)
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
            loading: \.$loadedLecturers,
            action: LecturersFeature.Action.view
        ) { store in
            WithViewStore(store) { lecturersViewStore in
                LecturersContentView(
                    searchQuery: viewStore.binding(\.$searchQuery),
                    favorites: viewStore.favorites,
                    lecturers: lecturersViewStore.state,
                    select: { lecturersViewStore.send(.value(.lecturerTapped($0))) },
                    refresh: { await lecturersViewStore.send(.refresh).finish() }
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
