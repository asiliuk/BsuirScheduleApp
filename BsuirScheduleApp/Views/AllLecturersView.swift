import SwiftUI
import BsuirUI

struct AllLecturersView: View {
    @ObservedObject var screen: AllLecturersScreen
    @Binding var selectedLecturer: Int?

    var body: some View {
        ContentStateWithSearchView(
            content: screen.lecturers,
            searchQuery: $screen.searchQuery,
            searchPlaceholder: "Найти преподавателя"
        ) { section in
            Section(header: section.header) {
                ForEach(section.lecturers, id: \.id) { lecturer in
                    NavigationLinkButton {
                        selectedLecturer = lecturer.id
                    } label: {
                        LecturerCell(lecturer: lecturer)
                    }
                }
            }
        } backgroundView: { sections in
            ForEach(sections) { section in
                ForEach(section.lecturers, id: \.id) { lecturer in
                    NavigationLink(
                        destination: ScheduleView(screen: screen.screen(for: lecturer)),
                        tag: lecturer.id,
                        selection: $selectedLecturer
                    ) { EmptyView() }
                }
            }
        }
        .navigationTitle("Все преподаватели")
    }
}

struct LecturerCell: View {
    let lecturer: AllLecturersScreenLecturer
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        if sizeCategory.isAccessibilityCategory {
            VStack(alignment: .leading) {
                Avatar(url: lecturer.imageURL)
                Text(lecturer.fullName)
            }
        } else {
            HStack {
                Avatar(url: lecturer.imageURL)
                Text(lecturer.fullName)
            }
        }
    }
}

private extension AllLecturersScreenGroupSection {
    @ViewBuilder var header: some View {
        switch section {
        case .favorites:
            Text("⭐️ Избранные")
        case .other:
            EmptyView()
        }
    }
}
