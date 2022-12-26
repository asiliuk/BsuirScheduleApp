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
                .modifier(StudentGroupsSearchable(
                    text: viewStore.binding(\.$query),
                    prompt: Text("screen.groups.search.placeholder"),
                    tokens: viewStore.binding(\.$tokens),
                    suggestedTokens: viewStore.binding(\.$suggestedTokens)
                ))
                .task(id: viewStore.query, throttleFor: 300_000_000) {
                    await viewStore.send(.filter, animation: .default).finish()
                }
        }
    }
}

private struct StudentGroupsSearchable: ViewModifier {
    @Binding var text: String
    var prompt: Text?
    @Binding var tokens: [StrudentGroupSearchToken]
    @Binding var suggestedTokens: [StrudentGroupSearchToken]

    func body(content: Content) -> some View {
        Group {
            if #available(iOS 16, *) {
                content
                    .searchable(
                        text: $text,
                        tokens: $tokens,
                        suggestedTokens: $suggestedTokens,
                        prompt: prompt,
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
                        })
            } else {
                content
                    .searchable(text: $text, prompt: prompt)
            }
        }
    }
}
