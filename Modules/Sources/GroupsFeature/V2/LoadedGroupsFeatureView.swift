import SwiftUI
import ComposableArchitecture
import BsuirUI
import Algorithms

struct LoadedGroupsFeatureView: View {
    @Perception.Bindable var store: StoreOf<LoadedGroupsFeature>
    let searchStore: StoreOf<GroupsSearch>
    let refresh: () async -> Void

    var body: some View {
        WithPerceptionTracking {
            ScrollableToTopList(isOnTop: $store.isOnTop) {

                GroupsSectionViewV2(
                    title: "screen.groups.pinned.section.header",
                    rows: store.scope(state: \.pinnedRow, action: \.groupRows)
                )

                GroupsSectionViewV2(
                    title: "screen.groups.favorites.section.header",
                    rows: store.scope(state: \.favoriteRows, action: \.groupRows)
                )

                let sections = store
                    .scope(state: \.visibleRows, action: \.groupRows)
                    .chunked(on: \.sectionTitle)

                ForEach(sections, id: \.0) { (sectionTitle, rows) in
                    GroupsSectionViewV2(
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
            .groupsSearchable(store: searchStore)
            .task { await store.send(.task).finish() }
        }
    }
}

private extension GroupsRowV2.State {
    var sectionTitle: Substring {
        title.prefix(3)
    }
}

private struct GroupsSectionViewV2<Rows>: View
where Rows: RandomAccessCollection, Rows.Element == StoreOf<GroupsRowV2> {
    var title: LocalizedStringKey
    var rows: Rows

    var body: some View {
        if !rows.isEmpty {
            Section(title) {
                ForEach(rows) { store in
                    GroupsRowViewV2(store: store)
                }
            }
        }
    }
}
