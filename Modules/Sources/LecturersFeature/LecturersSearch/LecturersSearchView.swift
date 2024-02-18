import SwiftUI
import BsuirUI
import ComposableArchitecture

extension View {
    func lecturersSearchable(store: StoreOf<LecturersSearch>) -> some View {
        modifier(LecturersSearchViewModifier(store: store))
    }
}

struct LecturersSearchViewModifier: ViewModifier {
    @Perception.Bindable var store: StoreOf<LecturersSearch>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .dismissSearch(store.dismiss)
                .searchable(
                    text: $store.query,
                    prompt: Text("screen.lecturers.search.placeholder")
                )
                .task(id: store.query) {
                    await store.send(.filter, animation: .default).finish()
                }
        }
    }
}
