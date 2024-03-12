import Foundation
import ComposableArchitecture
import Collections
import Favorites
import BsuirApi
import Algorithms

@Reducer
public struct LoadedGroupsFeature {
    @ObservableState
    public struct State: Equatable {
        // MARK: Search
        var searchQuery: String = ""
        var searchDismiss: Int = 0

        mutating func dismissSearch() {
            searchQuery = ""
            updateRows()
            searchDismiss += 1
        }

        fileprivate mutating func updateRows() {
            updatePinnedRows()
            updateFavoriteRows()
            updateVisibleRows()
        }

        private mutating func updatePinnedRows() {
            pinnedRows = IdentifiedArray(
                uniqueElements: [pinnedName]
                    .compacted()
                    .filter { $0.matches(query: searchQuery) }
                    .map { groupRows[id: $0].or(GroupsRow.State(groupName: $0)) }
            )
        }

        private mutating func updateFavoriteRows() {
            favoriteRows = IdentifiedArray(
                uniqueElements: favoritesNames
                    .filter { $0.matches(query: searchQuery) }
                    .map { groupRows[id: $0].or(GroupsRow.State(groupName: $0)) }
            )
        }

        private mutating func updateVisibleRows() {
            visibleRows = searchQuery.isEmpty
                ? groupRows
                : groupRows.filter { $0.groupName.matches(query: searchQuery) }
        }

        // MARK: Rows
        var isEmpty: Bool {
            visibleRows.isEmpty && pinnedRows.isEmpty && favoriteRows.isEmpty
        }

        var pinnedRows: IdentifiedArrayOf<GroupsRow.State> = []
        var favoriteRows: IdentifiedArrayOf<GroupsRow.State> = []
        var visibleRows: IdentifiedArrayOf<GroupsRow.State> = []

        // MARK: State
        fileprivate var favoritesNames: OrderedSet<String>
        fileprivate var pinnedName: String?
        fileprivate var groupRows: IdentifiedArrayOf<GroupsRow.State>

        init(
            groups: [StudentGroup],
            favoritesNames: OrderedSet<String>,
            pinnedName: String?
        ) {
            self.favoritesNames = favoritesNames
            self.pinnedName = pinnedName
            self.groupRows = IdentifiedArray(
                uniqueElements: groups
                    .sorted(by: { $0.name < $1.name })
                    .map(GroupsRow.State.init(group:))
            )
            updateRows()
        }
    }

    public enum Action: BindableAction, Equatable {
        public enum Delegate: Equatable {
            case showPremiumClub
        }

        case task

        case pinnedRows(IdentifiedActionOf<GroupsRow>)
        case favoriteRows(IdentifiedActionOf<GroupsRow>)
        case visibleRows(IdentifiedActionOf<GroupsRow>)

        case _favoritesUpdate(OrderedSet<String>)
        case _pinnedUpdate(String?)

        case delegate(Delegate)
        case binding(BindingAction<State>)
    }

    @Dependency(\.favorites.groupNames) var favoriteGroupNames
    @Dependency(\.pinnedScheduleService.schedule) var pinnedSchedule

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.searchQuery) { _, query in
                Reduce { state, _ in
                    if query.isEmpty {
                        state.dismissSearch()
                    } else {
                        state.updateRows()
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
                state.favoritesNames = value
                return .none

            case ._pinnedUpdate(let value):
                state.pinnedName = value
                return .none

            case .pinnedRows(.element(_, .mark(.delegate(let action)))),
                 .favoriteRows(.element(_, .mark(.delegate(let action)))),
                 .visibleRows(.element(_, .mark(.delegate(let action)))):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClub))
                }

            case .pinnedRows, .favoriteRows, .visibleRows, .binding, .delegate:
                return .none
            }
        }
        .forEach(\.pinnedRows, action: \.pinnedRows) {
            GroupsRow()
        }
        .forEach(\.favoriteRows, action: \.favoriteRows) {
            GroupsRow()
        }
        .forEach(\.visibleRows, action: \.visibleRows) {
            GroupsRow()
        }
        .onChange(of: \.pinnedName) { oldPinned, newPinned in
            Reduce { state, _ in
                return updatePinned(state: &state, oldPinned: oldPinned, newPinned: newPinned)
            }
        }
        .onChange(of: \.favoritesNames) { oldFavorites, newFavorites in
            Reduce { state, _ in
                return updateFavorites(state: &state, oldFavorites: oldFavorites, newFavorites: newFavorites)
            }
        }
    }

    private func listenToFavoriteUpdates() -> Effect<Action> {
        return .run { send in
            for await value in favoriteGroupNames.removeDuplicates().values {
                await send(._favoritesUpdate(value), animation: .default)
            }
        }
    }

    private func listenToPinnedUpdates() -> Effect<Action> {
        return .run { send in
            for await value in pinnedSchedule().map(\.?.groupName).removeDuplicates().values {
                await send(._pinnedUpdate(value), animation: .default)
            }
        }
    }

    private func updatePinned(
        state: inout State,
        oldPinned: String?,
        newPinned: String?
    ) -> Effect<Action> {
        if let newPinned {
            state.favoriteRows[id: newPinned]?.mark.isPinned = true
            state.visibleRows[id: newPinned]?.mark.isPinned = true
            state.groupRows[id: newPinned]?.mark.isPinned = true
            if newPinned.matches(query: state.searchQuery) {
                state.pinnedRows[id: newPinned] = state.groupRows[id: newPinned] ?? GroupsRow.State(groupName: newPinned)
            }
        }

        if let oldPinned {
            state.favoriteRows[id: oldPinned]?.mark.isPinned = false
            state.visibleRows[id: oldPinned]?.mark.isPinned = false
            state.groupRows[id: oldPinned]?.mark.isPinned = false
            state.pinnedRows.remove(id: oldPinned)
        }

        return .none
    }

    private func updateFavorites(
        state: inout State,
        oldFavorites: OrderedSet<String>,
        newFavorites: OrderedSet<String>
    ) -> Effect<Action> {
        for difference in newFavorites.difference(from: oldFavorites) {
            switch difference {
            case .insert(_, let groupName, _):
                state.pinnedRows[id: groupName]?.mark.isFavorite = true
                state.visibleRows[id: groupName]?.mark.isFavorite = true
                state.groupRows[id: groupName]?.mark.isFavorite = true
                if groupName.matches(query: state.searchQuery) {
                    state.favoriteRows[id: groupName] = state.groupRows[id: groupName] ?? GroupsRow.State(groupName: groupName)
                }
            case .remove(_, let groupName, _):
                state.pinnedRows[id: groupName]?.mark.isFavorite = false
                state.visibleRows[id: groupName]?.mark.isFavorite = false
                state.groupRows[id: groupName]?.mark.isFavorite = false
                state.favoriteRows.remove(id: groupName)
            }
        }
        return .none
    }
}

private extension String {
    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return localizedCaseInsensitiveContains(query)
    }
}
