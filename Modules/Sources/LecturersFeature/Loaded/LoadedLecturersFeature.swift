import Foundation
import ComposableArchitecture
import Collections
import BsuirApi
import Favorites

@Reducer
public struct LoadedLecturersFeature {
    @ObservableState
    public struct State {
        // MARK: Search
        var searchQuery: String = ""
        var searchDismiss: Int = 0

        mutating func dismissSearch() {
            searchQuery = ""
            searchDismiss += 1
            visibleRows = lecturerRows
        }

        // MARK: Rows

        var isEmpty: Bool {
            pinnedRows.isEmpty && favoriteRows.isEmpty && visibleRows.isEmpty
        }

        var pinnedRows: IdentifiedArrayOf<LecturersRow.State> {
            guard 
                let pinnedId = pinnedSchedule.source?.lector?.id,
                let row = visibleRows[id: pinnedId]
            else { return [] }
            return [row]
        }

        var favoriteRows: IdentifiedArrayOf<LecturersRow.State> {
            IdentifiedArray(uniqueElements: favoritesIds.compactMap { visibleRows[id: $0] })
        }

        var visibleRows: IdentifiedArrayOf<LecturersRow.State> = []

        // MARK: State

        func lector(withId id: Int) -> Employee? {
            lecturerRows[id: id]?.lector
        }

        @SharedReader(.favoriteLecturerIDs) var favoritesIds
        @SharedReader(.pinnedSchedule) var pinnedSchedule

        fileprivate var lecturerRows: IdentifiedArrayOf<LecturersRow.State> = []

        init(lecturers: [Employee]) {
            self.lecturerRows = IdentifiedArray(
                uniqueElements: lecturers
                    .map { LecturersRow.State(lector: $0) }
            )
            self.visibleRows = lecturerRows
        }
    }

    public enum Action: BindableAction {
        case lecturerRows(IdentifiedActionOf<LecturersRow>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.pinnedScheduleService.schedule) var pinnedSchedule

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.searchQuery) { _, query in
                Reduce { state, _ in
                    if query.isEmpty {
                        state.dismissSearch()
                    } else {
                        state.visibleRows = state.lecturerRows.filter { $0.matches(query: query) }
                    }
                    return .none
                }
            }
        Reduce { state, action in
            switch action {
            case .lecturerRows, .binding:
                return .none
            }
        }
        .forEach(\.lecturerRows, action: \.lecturerRows) {
            LecturersRow()
        }
        .forEach(\.visibleRows, action: \.lecturerRows) {
            LecturersRow()
        }
    }
}

private extension LecturersRow.State {
    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return lector.fio.localizedCaseInsensitiveContains(query)
    }
}
