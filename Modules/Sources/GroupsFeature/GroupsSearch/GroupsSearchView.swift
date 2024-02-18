import SwiftUI
import BsuirUI
import ComposableArchitecture

extension View {
    func groupsSearchable(store: StoreOf<GroupsSearch>) -> some View {
        modifier(GroupsSearchViewModifier(store: store))
    }
}

struct GroupsSearchViewModifier: ViewModifier {
    @Perception.Bindable var store: StoreOf<GroupsSearch>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .dismissSearch(store.dismiss)
                .searchable(
                    text: $store.query,
                    prompt: Text("screen.groups.search.placeholder")
                )
                .task(id: store.query) {
                    await store.send(.filter, animation: .default).finish()
                }
        }
    }
}
