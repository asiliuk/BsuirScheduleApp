import SwiftUI
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils

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
                    tokens: viewStore.binding(\.$tokens),
                    suggestedTokens: viewStore.binding(\.$suggestedTokens),
                    prompt: Text("screen.groups.search.placeholder"),
                    token: { token in
                        switch token {
                        case let .faculty(value):
                            Text(value)
                        case let .speciality(value):
                            Text(value)
                        case let .course(value?):
                            Text("screen.groups.search.suggested.course.\(String(value))")
                        case .course(nil):
                            Text("screen.groups.search.suggested.noCourse")
                        }
                    }
                )
                .task(id: viewStore.query, throttleFor: 300_000_000) {
                    await viewStore.send(.filter, animation: .default).finish()
                }
        }
    }
}
