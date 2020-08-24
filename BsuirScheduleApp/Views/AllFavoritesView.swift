import SwiftUI

struct AllFavoritesView: View {
    @ObservedObject var screen: AllFavoritesScreen

    var body: some View {
        List {
            if !screen.groups.isEmpty {
                Section(header: Text("Группы")) {
                    ForEach(screen.groups) { group in
                        NavigationLink(destination: ScheduleView(screen: screen.screen(for: group))) {
                            Text(group.name)
                        }
                    }
                }
            }

            if !screen.lecturers.isEmpty {
                Section(header: Text("Преподаватели")) {
                    ForEach(screen.lecturers) { lecturer in
                        NavigationLink(destination: ScheduleView(screen: screen.screen(for: lecturer))) {
                            LecturerCell(lecturer: lecturer)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Избранные")
    }
}
