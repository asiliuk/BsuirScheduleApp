import SwiftUI
import BsuirApi
import BsuirUI

struct GroupsContentView: View {
    let favorites: [String]
    let sections: [GroupsFeature.State.Section]
    let select: (String) -> Void
    let dismissSearch: Bool
    @Environment(\.dismissSearch) private var dismissSearchAction

    var body: some View {
        List {
            ScrollTopIdentifyingView()

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

