import SwiftUI

struct AllFavoritesView: View {
    enum Selection: Hashable {
        case group(id: Int)
        case lecturer(id: Int)
    }

    @ObservedObject var screen: AllFavoritesScreen
    @State var selection: Selection?

    var body: some View {
        List {
            if !screen.groups.isEmpty {
                Section(header: Text("Группы")) {
                    ForEach(screen.groups) { group in
                        NavigationLink(
                            destination: ScheduleView(screen: screen.screen(for: group)),
                            tag: .group(id: group.id),
                            selection: $selection
                        ) {
                            Text(group.name)
                        }
                    }
                }
            }

            if !screen.lecturers.isEmpty {
                Section(header: Text("Преподаватели")) {
                    ForEach(screen.lecturers) { lecturer in
                        NavigationLink(
                            destination: ScheduleView(screen: screen.screen(for: lecturer)),
                            tag: .lecturer(id: lecturer.id),
                            selection: $selection
                        ) {
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
