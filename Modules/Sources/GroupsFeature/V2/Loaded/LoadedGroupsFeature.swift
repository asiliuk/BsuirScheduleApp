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
        // MARK: Scroll
        var isOnTop: Bool = true

        // MARK: Search
        var searchQuery: String = ""
        var searchDismiss: Int = 0

        // MARK: Rows
        var isEmpty: Bool {
            visibleRows.isEmpty && pinnedRow.isEmpty && favoriteRows.isEmpty
        }

        var pinnedRow: IdentifiedArrayOf<GroupsRowV2.State> {
            guard let pinnedName else { return [] }
            return IdentifiedArray(
                uniqueElements: [GroupsRowV2.State(groupName: pinnedName)]
                    .filter { $0.matches(query: searchQuery) }
            )
        }

        var favoriteRows: IdentifiedArrayOf<GroupsRowV2.State> {
            IdentifiedArray(
                uniqueElements: favoritesNames
                    .map(GroupsRowV2.State.init)
                    .filter { $0.matches(query: searchQuery) }
            )
        }

        var visibleRows: IdentifiedArrayOf<GroupsRowV2.State> = []

        // MARK: State
        fileprivate var favoritesNames: OrderedSet<String>
        fileprivate var pinnedName: String?
        fileprivate var groupRows: IdentifiedArrayOf<GroupsRowV2.State> = []

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
                    .map { GroupsRowV2.State(groupName: $0.name) }
            )
            self.visibleRows = groupRows
        }
    }

    public enum Action: BindableAction, Equatable {
        case task
        case groupRows(IdentifiedActionOf<GroupsRowV2>)

        case _favoritesUpdate(OrderedSet<String>)
        case _pinnedUpdate(String?)

        case binding(BindingAction<State>)
    }

    @Dependency(\.favorites.groupNames) var favoriteGroupNames
    @Dependency(\.pinnedScheduleService.schedule) var pinnedSchedule

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.searchQuery) { _, query in
                Reduce { state, _ in
                    if query.isEmpty {
                        state.visibleRows = state.groupRows
                        state.searchDismiss += 1
                    } else {
                        state.visibleRows = state.groupRows.filter { $0.matches(query: query) }
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

            case .groupRows, .binding:
                return .none
            }
        }
        .forEach(\.groupRows, action: \.groupRows) {
            GroupsRowV2()
        }
        .forEach(\.visibleRows, action: \.groupRows) {
            GroupsRowV2()
        }
        .onChange(of: \.pinnedName) { oldPinned, newPinned in
            Reduce { state, _ in
                if let oldPinned { 
                    state.groupRows[id: oldPinned]?.mark.isPinned = false
                    state.visibleRows[id: oldPinned]?.mark.isPinned = false
                }
                if let newPinned {
                    state.groupRows[id: newPinned]?.mark.isPinned = true
                    state.visibleRows[id: newPinned]?.mark.isPinned = true
                }
                return .none
            }
        }
        .onChange(of: \.favoritesNames) { oldFavorites, newFavorites in
            Reduce { state, _ in
                for difference in newFavorites.difference(from: oldFavorites) {
                    switch difference {
                    case .insert(_, let groupName, _):
                        state.groupRows[id: groupName]?.mark.isFavorite = true
                        state.visibleRows[id: groupName]?.mark.isFavorite = true
                    case .remove(_, let groupName, _):
                        state.groupRows[id: groupName]?.mark.isFavorite = false
                        state.visibleRows[id: groupName]?.mark.isFavorite = false
                    }
                }
                return .none
            }
        }
    }

    private func listenToFavoriteUpdates() -> Effect<Action> {
        return .run { send in
            for await value in favoriteGroupNames.removeDuplicates().dropFirst().values {
                await send(._favoritesUpdate(value), animation: .default)
            }
        }
    }

    private func listenToPinnedUpdates() -> Effect<Action> {
        return .run { send in
            for await value in pinnedSchedule().map(\.?.groupName).removeDuplicates().dropFirst().values {
                await send(._pinnedUpdate(value), animation: .default)
            }
        }
    }
}

private extension GroupsRowV2.State {
    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return title.localizedCaseInsensitiveContains(query)
    }
}
