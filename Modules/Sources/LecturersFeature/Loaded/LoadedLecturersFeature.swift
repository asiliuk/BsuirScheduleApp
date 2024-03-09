import Foundation
import ComposableArchitecture
import Collections
import BsuirApi

@Reducer
public struct LoadedLecturersFeature {
    @ObservableState
    public struct State {
        // MARK: Scroll
        var isOnTop: Bool = true

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
            guard let pinnedId, let row = visibleRows[id: pinnedId] else { return [] }
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

        fileprivate var favoritesIds: OrderedSet<Int>
        fileprivate var pinnedId: Int?
        fileprivate var lecturerRows: IdentifiedArrayOf<LecturersRow.State> = []

        init(
            lecturers: [Employee],
            favoritesIds: OrderedSet<Int>,
            pinnedId: Int?
        ) {
            self.favoritesIds = favoritesIds
            self.pinnedId = pinnedId
            self.lecturerRows = IdentifiedArray(
                uniqueElements: lecturers
                    .map { LecturersRow.State(lector: $0) }
            )
            self.visibleRows = lecturerRows
        }
    }

    public enum Action: BindableAction {
        case task
        case lecturerRows(IdentifiedActionOf<LecturersRow>)

        case _favoritesUpdate(OrderedSet<Int>)
        case _pinnedUpdate(Int?)

        case binding(BindingAction<State>)
    }

    @Dependency(\.favorites.lecturerIds) var lecturerIds
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
            case .task:
                return .merge(
                    listenToFavoriteUpdates(),
                    listenToPinnedUpdates()
                )

            case ._favoritesUpdate(let value):
                state.favoritesIds = value
                return .none

            case ._pinnedUpdate(let value):
                state.pinnedId = value
                return .none

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
        .onChange(of: \.pinnedId) { oldPinned, newPinned in
            Reduce { state, _ in
                if let oldPinned {
                    state.lecturerRows[id: oldPinned]?.mark.isPinned = false
                    state.visibleRows[id: oldPinned]?.mark.isPinned = false
                }
                if let newPinned {
                    state.lecturerRows[id: newPinned]?.mark.isPinned = true
                    state.visibleRows[id: newPinned]?.mark.isPinned = true
                }
                return .none
            }
        }
        .onChange(of: \.favoritesIds) { oldFavorites, newFavorites in
            Reduce { state, _ in
                for difference in newFavorites.difference(from: oldFavorites) {
                    switch difference {
                    case .insert(_, let id, _):
                        state.lecturerRows[id: id]?.mark.isFavorite = true
                        state.visibleRows[id: id]?.mark.isFavorite = true
                    case .remove(_, let id, _):
                        state.lecturerRows[id: id]?.mark.isFavorite = false
                        state.visibleRows[id: id]?.mark.isFavorite = false
                    }
                }
                return .none
            }
        }
    }

    private func listenToFavoriteUpdates() -> Effect<Action> {
        return .run { send in
            for await value in lecturerIds.removeDuplicates().values {
                await send(._favoritesUpdate(value), animation: .default)
            }
        }
    }

    private func listenToPinnedUpdates() -> Effect<Action> {
        return .run { send in
            for await value in pinnedSchedule().map(\.?.lector?.id).removeDuplicates().values {
                await send(._pinnedUpdate(value), animation: .default)
            }
        }
    }
}

private extension LecturersRow.State {
    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return lector.fio.localizedCaseInsensitiveContains(query)
    }
}
