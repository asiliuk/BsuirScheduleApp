import SwiftUI
import BsuirApi
import BsuirUI

struct GroupsContentView: View {
    let pinned: String?
    let favorites: [String]
    let sections: [GroupsFeature.State.Section]
    let select: (String) -> Void
    let dismissSearch: Bool
    @Environment(\.dismissSearch) private var dismissSearchAction
    @Binding var isOnTop: Bool
    
    var body: some View {
        ScrollableToTopList(isOnTop: $isOnTop) {
            if let pinned {
                Section("screen.groups.pinned.section.header") {
                    GroupLinksView(
                        groups: [pinned],
                        select: select
                    )
                }
            }

            if !favorites.isEmpty {
                Section("screen.groups.favorites.section.header") {
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
        .onChange(of: dismissSearch) { dismiss in
            if dismiss { dismissSearchAction() }
        }
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

