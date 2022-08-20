import SwiftUI
import BsuirUI

struct AllLecturersView: View {
    @ObservedObject var screen: AllLecturersScreen

    var body: some View {
        ContentStateWithSearchView(
            content: screen.lecturers,
            searchQuery: $screen.searchQuery,
            searchPlaceholder: "Find a lecturer"
        ) { section in
            Section(header: section.header) {
                ForEach(section.lecturers) { lecturer in
                    NavigationLinkButton {
                        screen.selectedLecturer = lecturer
                    } label: {
                        LecturerCell(lecturer: lecturer)
                    }
                }
            }
        }
        .navigation(item: $screen.selectedLecturer) { lecturer in
            ScheduleView(screen: screen.screen(for: lecturer))
        }
        .navigationTitle("All lecturers")
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
            Text("⭐️ Favorites")
        case .other:
            EmptyView()
        }
    }
}
