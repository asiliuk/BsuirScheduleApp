import SwiftUI

struct SidebarRootView: View {
    let state: AppState
    @Binding var currentTab: CurrentTab?
    @State private var currentOverlay: Overlay? = nil

    var body: some View {
        NavigationView {
            Sidebar(state: state, currentTab: $currentTab, currentOverlay: $currentOverlay)

            switch currentTab {
            case nil, .groups:
                AllGroupsView(screen: state.allGroups)
            case .lecturers:
                AllLecturersView(screen: state.allLecturers)
            case .about:
                AboutView()
            case let .favorites(selection):
                AllFavoritesView(screen: state.allFavorites, selection: selection)
            }

            SchedulePlaceholder()
        }
        .sheet(item: $currentOverlay) {
            switch $0 {
            case .about:
                NavigationView { AboutView() }
            }
        }
    }
}

private struct Sidebar: View {
    let state: AppState
    @Binding var currentTab: CurrentTab?
    @Binding var currentOverlay: Overlay?

    var body: some View {
        List {
            NavigationLink(
                destination: AllGroupsView(screen: state.allGroups),
                tag: .groups,
                selection: $currentTab
            ) {
                CurrentTab.groups.label
            }

            NavigationLink(
                destination: AllLecturersView(screen: state.allLecturers),
                tag: .lecturers,
                selection: $currentTab
            ) {
                CurrentTab.lecturers.label
            }

            Button(action: { currentOverlay = .about }) {
                CurrentTab.about.label
            }

            FavoritesDisclosureGroup(allFavorites: state.allFavorites, currentTab: $currentTab)
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Расписание")
    }
}

private struct FavoritesDisclosureGroup: View {
    @ObservedObject var allFavorites: AllFavoritesScreen
    @Binding var currentTab: CurrentTab?

    @ViewBuilder var body: some View {
        if !allFavorites.isEmpty {
            DisclosureGroup(
                content: {
                    ForEach(allFavorites.groups) { group in
                        NavigationLink(
                            destination: AllFavoritesView(screen: allFavorites, selection: .group(id: group.id)),
                            tag: .favorites(selection: .group(id: group.id)),
                            selection: $currentTab
                        ) {
                            Text(group.name)
                        }
                    }

                    ForEach(allFavorites.lecturers) { lecturer in
                        NavigationLink(
                            destination: AllFavoritesView(screen: allFavorites, selection: .lecturer(id: lecturer.id)),
                            tag: .favorites(selection: .lecturer(id: lecturer.id)),
                            selection: $currentTab
                        ) {
                            Text(lecturer.fullName)
                        }
                    }
                },
                label: {
                    NavigationLink(
                        destination: AllFavoritesView(screen: allFavorites, selection: nil),
                        tag: .favorites(),
                        selection: $currentTab
                    ) {
                        CurrentTab.favorites().label
                    }
                }
            )
        }
    }
}

fileprivate enum Overlay: Identifiable {
    var id: Self { self }
    case about
}

private struct SchedulePlaceholder: View {
    var body: some View {
        Text("Please select schedule to view...")
    }
}
