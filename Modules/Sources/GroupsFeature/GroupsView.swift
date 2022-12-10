import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture

public struct GroupsView: View {
    public let store: StoreOf<GroupsFeature>
    
    public init(store: StoreOf<GroupsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LoadingGroupsView(
                viewStore: viewStore,
                store: store
            )
            .navigationTitle("screen.groups.navigation.title")
            .task { await viewStore.send(.task).finish() }
            .task(id: viewStore.searchQuery) {
                do {
                    try await Task.sleep(nanoseconds: 300_000_000)
                    await viewStore.send(.filterGroups, animation: .default).finish()
                } catch {}
            }
            .navigation(item: viewStore.binding(\.$groupSchedule)) { _ in
                IfLetStore(
                    store
                        .scope(state: \.groupSchedule, action: { .groupSchedule($0) })
                        .returningLastNonNilState()
                ) { store in
                    GroupScheduleView(store: store)
                }
            }
        }
    }
}

private struct LoadingGroupsView: View {
    let viewStore: ViewStoreOf<GroupsFeature>
    let store: StoreOf<GroupsFeature>
    
    var body: some View {
        LoadingStore(
            store,
            state: \.$sections,
            loading: \.$loadedGroups
        ) { store in
            WithViewStore(store) { sectionsViewStore in
                GroupsContentView(
                    favorites: viewStore.favorites,
                    sections: sectionsViewStore.state,
                    select: { viewStore.send(.groupTapped(name: $0)) },
                    dismissSearch: viewStore.dismissSearch
                )
                .refreshable { await sectionsViewStore.send(.refresh).finish() }
                .modifier(StudentGroupSearchable(
                    text: viewStore.binding(\.$searchQuery),
                    prompt: Text("screen.groups.search.placeholder"),
                    tokens: viewStore.binding(\.$searchTokens),
                    suggestedTokens: viewStore.binding(\.$searchSuggestedTokens)
                ))
                .scrollableToTop(isOnTop: viewStore.binding(\.$isOnTop))
            }
        } loading: {
            LoadingStateView()
        } error: { store in
            LoadingErrorView(store: store)
        }
    }
}

struct StudentGroupSearchable: ViewModifier {
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
