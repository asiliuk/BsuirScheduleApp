import SwiftUI
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils

extension View {
    func lecturersSearchable(store: StoreOf<LecturersSearch>) -> some View {
        modifier(LecturersSearchViewModifier(store: store))
    }
}

struct LecturersSearchViewModifier: ViewModifier {
    let store: StoreOf<LecturersSearch>

    func body(content: Content) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content
                .dismissSearch(viewStore.dismiss)
                .searchable(
                    text: viewStore.binding(\.$query),
                    prompt: Text("screen.lecturers.search.placeholder")
                )
                .task(id: viewStore.query, throttleFor: 300_000_000) {
                    await viewStore.send(.filter, animation: .default).finish()
                }
        }
    }
}
