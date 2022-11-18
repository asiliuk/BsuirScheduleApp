import SwiftUI
import BsuirApi
import BsuirUI

struct GroupsContentView: View {
    @Binding var searchQuery: String
    let favorites: [String]
    let sections: [GroupsFeature.State.Section]
    let select: (String) -> Void
    let refresh: () async -> Void
    
    var body: some View {
        List {
            if !favorites.isEmpty {
                Section(header: Text("screen.groups.favorites.section.header")) {
                    GroupLinksView(
                        groups: favorites,
                        select: select
                    )
                }
            }
            
            ForEach(sections) { section in
                Section(header: Text(section.title)) {
                    GroupLinksView(
                        groups: section.groups.map(\.name),
                        select: select
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await refresh() }
        .searchable(
            text: $searchQuery,
            prompt: Text("screen.groups.search.placeholder")
        )
    }
}

private struct GroupLinksView: View {
    let groups: [String]
    let select: (String) -> Void
    
    var body: some View {
        ForEach(groups, id: \.self) { group in
            NavigationLinkButton {
                select(group)
            } label: {
                Text(group).monospacedDigit()
            }
        }
    }
}

