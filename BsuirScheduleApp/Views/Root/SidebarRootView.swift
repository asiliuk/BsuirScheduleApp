import SwiftUI

struct SidebarRootView: View {
    let state: AppState
    @Binding var currentSelection: CurrentSelection?
    @Binding var currentOverlay: CurrentOverlay?

    var body: some View {
        NavigationView {
            Sidebar(state: state, currentSelection: $currentSelection, currentOverlay: $currentOverlay)

            switch currentSelection {
            case nil, .groups:
                AllGroupsView(screen: state.allGroups, selectedGroup: $currentSelection.selectedGroup)
            case .lecturers:
                AllLecturersView(screen: state.allLecturers, selectedLecturer: $currentSelection.selectedLecturer)
            case .about:
                AboutView(screen: state.about)
            case let .favorites(selection):
                AllFavoritesView(screen: state.allFavorites, selection: selection, openGroups: { currentSelection = .groups() })
            }

            SchedulePlaceholder()
        }
    }
}

private struct Sidebar: View {
    let state: AppState
    @Binding var currentSelection: CurrentSelection?
    @Binding var currentOverlay: CurrentOverlay?

    var body: some View {
        List {
            NavigationLink(
                destination: AllGroupsView(screen: state.allGroups, selectedGroup: $currentSelection.selectedGroup),
                tag: .groups(),
                selection: $currentSelection
            ) {
                CurrentSelection.groups().label
            }

            NavigationLink(
                destination: AllLecturersView(screen: state.allLecturers, selectedLecturer: $currentSelection.selectedLecturer),
                tag: .lecturers(),
                selection: $currentSelection
            ) {
                CurrentSelection.lecturers().label
            }

            Button(action: { currentOverlay = .about }) {
                CurrentSelection.about.label
            }

            FavoritesDisclosureGroup(allFavorites: state.allFavorites, currentSelection: $currentSelection)
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Расписание")
    }
}

private struct FavoritesDisclosureGroup: View {
    @ObservedObject var allFavorites: AllFavoritesScreen
    @Binding var currentSelection: CurrentSelection?
    @State private var isExpanded: Bool = true

    @ViewBuilder var body: some View {
        if !allFavorites.isEmpty {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    ForEach(allFavorites.groups) { group in
                        NavigationLink(
                            destination: AllFavoritesView(
                                screen: allFavorites,
                                selection: .group(id: group.id),
                                openGroups: { currentSelection = .groups() }
                            ),
                            tag: .favorites(selection: .group(id: group.id)),
                            selection: $currentSelection
                        ) {
                            Text(group.name)
                        }
                    }

                    ForEach(allFavorites.lecturers) { lecturer in
                        NavigationLink(
                            destination: AllFavoritesView(
                                screen: allFavorites,
                                selection: .lecturer(id: lecturer.id),
                                openGroups: { currentSelection = .groups() }
                            ),
                            tag: .favorites(selection: .lecturer(id: lecturer.id)),
                            selection: $currentSelection
                        ) {
                            Text(lecturer.fullName)
                        }
                    }
                },
                label: {
                    NavigationLink(
                        destination: AllFavoritesView(
                            screen: allFavorites,
                            selection: nil,
                            openGroups: { currentSelection = .groups() }
                        ),
                        tag: .favorites(),
                        selection: $currentSelection
                    ) {
                        CurrentSelection.favorites().label
                    }
                }
            )
        }
    }
}

private struct SchedulePlaceholder: View {
    var body: some View {
        Text("Пожалуйста, выберите расписание чтобы отобразить...")
    }
}
