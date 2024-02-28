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
        var isOnTop: Bool = true
        var isEmpty: Bool { visibleRows.isEmpty }

        var pinnedRow: IdentifiedArrayOf<GroupsRowV2.State> {
            guard let pinnedName else { return [] }
            return IdentifiedArray(uniqueElements: [GroupsRowV2.State(groupName: pinnedName)])
        }

        var favoriteRows: IdentifiedArrayOf<GroupsRowV2.State> {
            IdentifiedArray(uniqueElements: favoritesNames.map(GroupsRowV2.State.init))
        }

        var visibleRows: IdentifiedArrayOf<GroupsRowV2.State> {
            groupRows
        }

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

            case .groupRows(.element(let id, .rowTapped)):
                print("row rapped \(id)")
                return .none

            case .groupRows, .binding:
                return .none
            }
        }
        .forEach(\.groupRows, action: \.groupRows) {
            GroupsRowV2()
        }
//        .onChange(of: \.pinnedName) { oldPinned, newPinned in
//            Reduce { state, _ in
//                if let oldPinned {
//                    state[groupSection: oldPinned]?[groupNamed: oldPinned]?.mark.isPinned = false
//                }
//
//                if let newPinned {
//                    state[groupSection: newPinned]?[groupNamed: newPinned]?.mark.isPinned = true
//                }
//
//                return .none
//            }
//        }
//        .onChange(of: \.favoritesNames) { oldFavorites, newFavorites in
//            Reduce { state, _ in
//                for difference in oldFavorites.difference(from: newFavorites) {
//                    switch difference {
//                    case .insert(_, let groupName, _):
//                        state[groupSection: groupName]?[groupNamed: groupName]?.mark.isFavorite = true
//                    case .remove(_, let groupName, _):
//                        state[groupSection: groupName]?[groupNamed: groupName]?.mark.isFavorite = false
//                    }
//                }
//                return .none
//            }
//        }
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
