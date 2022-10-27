import SwiftUI
import BsuirApi
import BsuirUI

struct LecturersContentView: View {
    @Binding var searchQuery: String
    let favorites: [Employee]
    let lecturers: [Employee]
    let select: (Employee) -> Void
    let refresh: () async -> Void
    
    var body: some View {
        List {
            if !favorites.isEmpty {
                Section(header: Text("screen.lecturers.favorites.section.header")) {
                    EmployeeLinksView(
                        lecturers: favorites,
                        select: select
                    )
                }
            }
            
            Section {
                EmployeeLinksView(
                    lecturers: lecturers,
                    select: select
                )
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await refresh() }
        .searchable(
            text: $searchQuery,
            prompt: Text("screen.lecturers.search.placeholder")
        )
    }
}

private struct EmployeeLinksView: View {
    let lecturers: [Employee]
    let select: (Employee) -> Void

    var body: some View {
        ForEach(lecturers) { lector in
            NavigationLinkButton {
                select(lector)
            } label: {
                LecturerCellView(
                    fullName: lector.fio,
                    imageUrl: lector.photoLink
                )
            }
        }
    }
}

