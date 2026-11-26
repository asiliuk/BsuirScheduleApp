import SwiftUI
import BsuirApi
import ComposableArchitecture
import ScheduleCore

struct LoadedGroupsView: View {
    let store: StoreOf<LoadedGroupsFeature>
    let refresh: () async -> Void

    var body: some View {
        List {
            if let pinnedGroup = store.pinnedGroup {
                Section {
                    GroupRow(group: pinnedGroup) {
                        store.send(.rowTapped($0))
                    }
                } header: {
                    Text(.sectionPinnedHeaderTitle)
                }
            }

            let favoriteGroups = store.favoriteGroups
            if !favoriteGroups.isEmpty {
                Section {
                    ForEach(favoriteGroups.enumerated(), id: \.offset) { (_, group) in
                        GroupRow(group: group) {
                            store.send(.rowTapped($0))
                        }
                    }
                } header: {
                    Text(.sectionFavoritesHeaderTitle)
                }
            }

            Section {
                ForEach(store.groups) { group in
                    GroupRow(group: group) {
                        store.send(.rowTapped($0))
                    }
                }
            } header: {
                Text(.sectionGroupsHeaderTitle)
            }
        }
        .refreshable { await refresh() }
    }
}

private struct GroupRow: View {
    let group: StudentGroup
    let onTap: (String) -> Void

    var body: some View {
        Button(group.name) {
            onTap(group.name)
        }
    }
}
