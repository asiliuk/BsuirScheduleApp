import Foundation
import ComposableArchitecture
import Collections
import Favorites
import BsuirApi
import Algorithms

@Reducer
public struct LoadedGroupsFeature {
    @ObservableState
    public struct State {
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

        fileprivate mutating func updatePinnedRows(groupName: String?? = nil) {
            pinnedRows = IdentifiedArray(
                uniqueElements: [groupName ?? pinnedSchedule.source?.groupName]
                    .compacted()
                    .filter { $0.matches(query: searchQuery) }
                    .map { groupRows[id: $0].or(GroupsRow.State(groupName: $0)) }
            )
        }

        fileprivate mutating func updateFavoriteRows(favoritesNames: [String]? = nil) {
            favoriteRows = IdentifiedArray(
                uniqueElements: (favoritesNames ?? self.favoritesNames)
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
        @SharedReader(.favoriteGroupNames) var favoritesNames
        @SharedReader(.pinnedSchedule) var pinnedSchedule
        fileprivate var groupRows: IdentifiedArrayOf<GroupsRow.State>

        init(groups: [StudentGroup]) {
            self.groupRows = IdentifiedArray(
                uniqueElements: groups
                    .sorted(by: { $0.name < $1.name })
                    .map(GroupsRow.State.init(group:))
            )
            updateRows()
        }
    }

    public enum Action: BindableAction {
        public enum Delegate {
            case showPremiumClub
        }

        case task

        case pinnedRows(IdentifiedActionOf<GroupsRow>)
        case favoriteRows(IdentifiedActionOf<GroupsRow>)
        case visibleRows(IdentifiedActionOf<GroupsRow>)

        case _favoritesUpdate([String])
        case _pinnedUpdate(String?)

        case delegate(Delegate)
        case binding(BindingAction<State>)
    }

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
                    .publisher {
                        state.$favoritesNames.publisher
                            .map(Action._favoritesUpdate)
                    },
                    .publisher {
                        state.$pinnedSchedule.publisher
                            .map { $0.source?.groupName }
                            .removeDuplicates()
                            .map(Action._pinnedUpdate)
                    }
                )

            case ._favoritesUpdate(let newValue):
                state.updateFavoriteRows(favoritesNames: newValue)
                return .none

            case ._pinnedUpdate(let newValue):
                state.updatePinnedRows(groupName: newValue)
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
    }
}

private extension String {
    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return localizedCaseInsensitiveContains(query)
    }
}
