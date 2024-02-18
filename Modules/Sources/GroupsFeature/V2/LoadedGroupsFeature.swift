import Foundation
import ComposableArchitecture
import Collections
import Favorites
import BsuirApi

@Reducer
public struct LoadedGroupsFeature {
    @ObservableState
    public struct State: Equatable {
        var isOnTop: Bool = true

        fileprivate var favoritesNames: OrderedSet<String>
        fileprivate var pinnedName: String?
        fileprivate var sections: IdentifiedArrayOf<GroupsSection.State> = []

        init(
            groups: [StudentGroup],
            favoritesNames: OrderedSet<String>,
            pinnedName: String?
        ) {
            self.favoritesNames = favoritesNames
            self.pinnedName = pinnedName
        }
    }

    public enum Action: BindableAction, Equatable {
        case task

        case _favoritesUpdate(OrderedSet<String>)
        case _pinnedUpdate(String?)

        case sections(IdentifiedActionOf<GroupsSection>)
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

            case .sections, .binding:
                return .none
            }
        }
        .forEach(\.sections, action: \.sections) {
            GroupsSection()
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
