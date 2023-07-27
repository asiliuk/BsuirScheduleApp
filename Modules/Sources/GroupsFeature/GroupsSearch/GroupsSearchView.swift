import SwiftUI
import BsuirUI
import ComposableArchitecture

extension View {
    func groupsSearchable(store: StoreOf<GroupsSearch>) -> some View {
        modifier(GroupsSearchViewModifier(store: store))
    }
}

struct GroupsSearchViewModifier: ViewModifier {
    let store: StoreOf<GroupsSearch>

    func body(content: Content) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content
                .dismissSearch(viewStore.dismiss)
                .searchable(
                    text: viewStore.binding(\.$query),
                    prompt: Text("screen.groups.search.placeholder")
                )
                .task(id: viewStore.query, throttleFor: .milliseconds(300)) {
                    await viewStore.send(.filter, animation: .default).finish()
                }
        }
    }
}
