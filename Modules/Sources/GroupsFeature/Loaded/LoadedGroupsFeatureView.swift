import SwiftUI
import ComposableArchitecture
import BsuirUI
import Algorithms

struct LoadedGroupsFeatureView: View {
    @Perception.Bindable var store: StoreOf<LoadedGroupsFeature>
    let refresh: () async -> Void

    var body: some View {
        WithPerceptionTracking {
            ScrollableToTopList(isOnTop: $store.isOnTop) {

                GroupsSectionView(
                    title: "screen.groups.pinned.section.header",
                    rows: store.scope(state: \.pinnedRows, action: \.pinnedRows)
                )

                GroupsSectionView(
                    title: "screen.groups.favorites.section.header",
                    rows: store.scope(state: \.favoriteRows, action: \.favoriteRows)
                )

                let sections = store
                    .scope(state: \.visibleRows, action: \.visibleRows)
                    .chunked(on: \.sectionTitle)

                ForEach(sections, id: \.0) { (sectionTitle, rows) in
                    GroupsSectionView(
                        title: LocalizedStringKey(String(sectionTitle)),
                        rows: rows
                    )
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await refresh() }
            .overlay {
                if #available(iOS 17, *) {
                    if store.isEmpty {
                        ContentUnavailableView.search
                    }
                }
            }
            .dismissSearch(store.searchDismiss)
            .searchable(text: $store.searchQuery, prompt: "screen.groups.search.placeholder")
            .task { await store.send(.task).finish() }
        }
    }
}

private extension GroupsRow.State {
    var sectionTitle: Substring {
        title.prefix(3)
    }
}

private struct GroupsSectionView<Rows>: View
where Rows: RandomAccessCollection, Rows.Element == StoreOf<GroupsRow> {
    var title: LocalizedStringKey
    var rows: Rows

    var body: some View {
        if !rows.isEmpty {
            Section(title) {
                ForEach(rows) { store in
                    GroupsRowView(store: store)
                }
            }
        }
    }
}
