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
            WithViewStore(
                store.scope(state: \.lecturers, action: { .loadableLecturers($0) }),
                observe: { $0 }
            ) { loadingViewStore in
                ZStack {
                    switch loadingViewStore.state {
                    case .initial, .loading:
                        LoadingStateView()
                    case .error:
                        ErrorStateView(retry: { loadingViewStore.send(.reload) })
                    case let .some(value):
                        LecturersContentView(
                            searchQuery: viewStore.binding(\.$searchQuery),
                            favorites: viewStore.favorites,
                            lecturers: value,
                            select: { viewStore.send(.lecturerTapped($0)) },
                            refresh: { await loadingViewStore.send(.refresh).finish() }
                        )
                    }
                }
                .task { await loadingViewStore.send(.task).finish() }
            }
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
