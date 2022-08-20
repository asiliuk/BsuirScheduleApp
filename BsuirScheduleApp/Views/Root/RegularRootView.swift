import SwiftUI

struct RegularRootView: View {
    let state: AppState
    @Binding var currentSelection: CurrentSelection?
    @Binding var currentOverlay: CurrentOverlay?

    var body: some View {
        NavigationView {
            TabView(selection: $currentSelection) {
                // Placeholder
                // When in NavigationView first tab is not visible on iPad
                Text("Oops").opacity(0)

                AllFavoritesView(screen: state.allFavorites, openGroups: { currentSelection = .groups })
                    .tab(.favorites)

                AllGroupsView(screen: state.allGroups)
                    .tab(.groups)

                AllLecturersView(screen: state.allLecturers)
                    .tab(.lecturers)
            }
            .toolbar {
                Button {
                    currentOverlay = .about
                } label: {
                    CurrentSelection.about.label
                }
            }

            SchedulePlaceholder()
        }
    }
}

//private struct Sidebar: View {
//    let state: AppState
//    @Binding var currentSelection: CurrentSelection?
//    @Binding var currentOverlay: CurrentOverlay?
//
//    var body: some View {
//        List {
//            NavigationLink(
//                destination: AllGroupsView(screen: state.allGroups),
//                tag: .groups,
//                selection: $currentSelection
//            ) {
//                CurrentSelection.groups.label
//            }
//
//            NavigationLink(
//                destination: AllLecturersView(screen: state.allLecturers),
//                tag: .lecturers,
//                selection: $currentSelection
//            ) {
//                CurrentSelection.lecturers.label
//            }
//
//            Button(action: { currentOverlay = .about }) {
//                CurrentSelection.about.label
//            }
//
//            NavigationLink(
//                destination: AllFavoritesView(
//                    screen: state.allFavorites,
//                    openGroups: { currentSelection = .groups }
//                ),
//                tag: .favorites,
//                selection: $currentSelection
//            ) {
//                CurrentSelection.favorites.label
//            }
//        }
//        .listStyle(SidebarListStyle())
//        .navigationTitle("Расписание")
//    }
//}

//private struct FavoritesDisclosureGroup: View {
//    @ObservedObject var allFavorites: AllFavoritesScreen
//    @Binding var currentSelection: CurrentSelection?
//    @State private var isExpanded: Bool = true
//
//    @ViewBuilder var body: some View {
//        if !allFavorites.isEmpty {
//            DisclosureGroup(
//                isExpanded: $isExpanded,
//                content: {
//                    ForEach(allFavorites.groups) { group in
//                        NavigationLink(
//                            destination: AllFavoritesView(
//                                screen: allFavorites,
//                                selection: .group(id: group.id),
//                                openGroups: { currentSelection = .groups }
//                            ),
//                            tag: .favorites(selection: .group(id: group.id)),
//                            selection: $currentSelection
//                        ) {
//                            Text(group.name)
//                        }
//                    }
//
//                    ForEach(allFavorites.lecturers) { lecturer in
//                        NavigationLink(
//                            destination: AllFavoritesView(
//                                screen: allFavorites,
//                                selection: .lecturer(id: lecturer.id),
//                                openGroups: { currentSelection = .groups }
//                            ),
//                            tag: .favorites(selection: .lecturer(id: lecturer.id)),
//                            selection: $currentSelection
//                        ) {
//                            Text(lecturer.fullName)
//                        }
//                    }
//                },
//                label: {
//                    NavigationLink(
//                        destination: AllFavoritesView(
//                            screen: allFavorites,
//                            selection: nil,
//                            openGroups: { currentSelection = .groups }
//                        ),
//                        tag: .favorites(),
//                        selection: $currentSelection
//                    ) {
//                        CurrentSelection.favorites().label
//                    }
//                }
//            )
//        }
//    }
//}

private struct SchedulePlaceholder: View {
    var body: some View {
        Text("Please select a schedule to display...")
    }
}
