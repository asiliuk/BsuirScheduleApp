import SwiftUI
import BsuirApi
import BsuirUI

struct GroupsContentView: View {
    @Binding var searchQuery: String
    let favorites: [StudentGroup]
    let sections: [GroupsFeature.State.Section]
    let select: (StudentGroup) -> Void
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
                        groups: section.groups,
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
    let groups: [StudentGroup]
    let select: (StudentGroup) -> Void
    
    var body: some View {
        ForEach(groups) { group in
            NavigationLinkButton {
                select(group)
            } label: {
                Text(group.name).monospacedDigit()
            }
        }
    }
}

