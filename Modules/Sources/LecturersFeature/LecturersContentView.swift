import SwiftUI
import BsuirApi
import BsuirUI
import IdentifiedCollections

struct LecturersContentView: View {
    let pinned: Employee?
    let favorites: IdentifiedArrayOf<Employee>
    let lecturers: IdentifiedArrayOf<Employee>
    let select: (Employee) -> Void
    let dismissSearch: Bool
    @Environment(\.dismissSearch) private var dismissSearchAction
    
    var body: some View {
        List {
            ScrollTopIdentifyingView()

            if let pinned {
                Section("screen.lecturers.pinned.section.header") {
                    EmployeeLinksView(
                        lecturers: [pinned],
                        select: select
                    )
                }
            }
            
            if !favorites.isEmpty {
                Section("screen.lecturers.favorites.section.header") {
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
        .onChange(of: dismissSearch) { dismiss in
            if dismiss { dismissSearchAction() }
        }
    }
}

private struct EmployeeLinksView: View {
    let lecturers: IdentifiedArrayOf<Employee>
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

