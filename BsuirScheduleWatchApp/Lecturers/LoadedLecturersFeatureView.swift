import SwiftUI
import BsuirApi
import ComposableArchitecture
import BsuirUI

struct LoadedLecturersFeatureView: View {
    let store: StoreOf<LoadedLecturersFeature>
    let refresh: () async -> Void

    var body: some View {
        List {
            if let pinnedLecturer = store.pinnedLecturer {
                Section {
                    LecturerRow(lecturer: pinnedLecturer) {
                        store.send(.rowTapped($0))
                    }
                } header: {
                    Text(.sectionPinnedHeaderTitle)
                }
            }

            let favoriteLecturers = store.favoriteLecturers
            if !favoriteLecturers.isEmpty {
                Section {
                    ForEach(favoriteLecturers) { lecturer in
                        LecturerRow(lecturer: lecturer) {
                            store.send(.rowTapped($0))
                        }
                    }
                } header: {
                    Text(.sectionFavoritesHeaderTitle)
                }
            }

            Section {
                ForEach(store.lecturers) { lecturer in
                    LecturerRow(lecturer: lecturer) {
                        store.send(.rowTapped($0))
                    }
                }
            } header: {
                Text(.sectionLecturersHeaderTitle)
            }
        }
        .refreshable { await refresh() }
    }
}

private struct LecturerRow: View {
    let lecturer: Employee
    let onTap: (Employee) -> Void

    var body: some View {
        Button {
            onTap(lecturer)
        } label: {
            HStack {
                Avatar(
                    url: lecturer.actualPhotoLink,
                    baseSize: 32
                )
                Text(verbatim: lecturer.compactFio)
            }
        }
    }
}
