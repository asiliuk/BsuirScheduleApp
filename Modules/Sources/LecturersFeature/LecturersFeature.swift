import Foundation
import BsuirApi
import BsuirCore
import LoadableFeature
import EntityScheduleFeature
import ScheduleFeature
import ComposableArchitecture
import Favorites
import Collections

@Reducer
public struct LecturersFeature {
    public struct State: Equatable {
        var path = StackState<EntityScheduleFeature.State>()
        var search: LecturersSearch.State = .init()
        @LoadableState var lecturers: IdentifiedArrayOf<LecturersRow.State>?
        var isOnTop: Bool = true

        var pinned: LecturersRow.State?
        var favorites: IdentifiedArrayOf<LecturersRow.State> = []

        fileprivate var pinnedLector: Employee? = {
            @Dependency(\.pinnedScheduleService.currentSchedule) var pinnedSchedule
            return pinnedSchedule()?.lector
        }()

        var favoritesPlaceholderCount: Int { favoriteIds.count }

        fileprivate var favoriteIds: OrderedSet<Int> = {
            @Dependency(\.favorites.currentLectorIds) var currentLectorIds
            return currentLectorIds
        }()

        @LoadableState var loadedLecturers: IdentifiedArrayOf<Employee>?

        // When deeplink was opened but no lecturers yet loaded
        struct LectorScheduleDeferredDetails: Equatable {
            let id: Int
            let displayType: ScheduleDisplayType
        }
        var lectorToOpen: LectorScheduleDeferredDetails?

        public init() {}
    }

    public enum Action: Equatable, LoadableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
        }

        case path(StackAction<EntityScheduleFeature.State, EntityScheduleFeature.Action>)
        case search(LecturersSearch.Action)
        case pinned(LecturersRow.Action)
        case favorites(IdentifiedActionOf<LecturersRow>)
        case lectors(IdentifiedActionOf<LecturersRow>)

        case task
        case setIsOnTop(Bool)
        
        case _favoritesUpdate(OrderedSet<Int>)
        case _pinnedUpdate(Employee?)

        case loading(LoadingAction<State>)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites) var favorites
    @Dependency(\.pinnedScheduleService.schedule) var pinnedSchedule

    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { coreReduce(into: &$0, action: $1) }
        .ifLet(\.pinned, action: \.pinned) {
            LecturersRow()
        }
        .forEach(\.favorites, action: \.favorites) {
            LecturersRow()
        }
        .ifLet(\.lecturers, action: \.lectors) {
            EmptyReducer()
                .forEach(\.self, action: \.self) {
                    LecturersRow()
                }
        }
        .load(\.$loadedLecturers) { _, isRefresh in
            try await IdentifiedArray(uniqueElements: apiClient.lecturers(isRefresh))
        }
        .forEach(\.path, action: \.path) {
            EntityScheduleFeature()
        }

        Scope(state: \.search, action: \.search) {
            LecturersSearch()
        }
    }

    private func coreReduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .merge(
                listenToFavoriteUpdates(),
                listenToPinnedUpdates()
            )

        case let .setIsOnTop(value):
            state.isOnTop = value
            return .none

        case .pinned(.rowTapped):
            let lector = state.pinned?.lector
            state.presentLector(lector)
            return .none

        case let .favorites(.element(id, .rowTapped)):
            let lector = state.favorites[id: id]?.lector
            state.presentLector(lector)
            return .none

        case let .lectors(.element(id, .rowTapped)):
            let lector = state.loadedLecturers?[id: id]
            state.presentLector(lector)
            return .none

        case .loading(.started(\.$loadedLecturers)):
            filteredLecturers(state: &state)
            filteredFavorites(state: &state)
            filteredPinned(state: &state)
            return .none

        case .loading(.finished(\.$loadedLecturers)):
            filteredLecturers(state: &state)
            filteredFavorites(state: &state)
            filteredPinned(state: &state)
            state.openLectorIfNeeded()
            return .none

        case .search(.delegate(.didUpdateImportantState)):
            filteredLecturers(state: &state)
            filteredFavorites(state: &state)
            filteredPinned(state: &state)
            return .none

        case let ._favoritesUpdate(value):
            state.favoriteIds = value
            filteredFavorites(state: &state)
            return .none

        case let ._pinnedUpdate(value):
            state.pinnedLector = value
            filteredPinned(state: &state)
            return .none

        case .favorites(.element(_, .mark(.delegate(let action)))),
                .lectors(.element(_, .mark(.delegate(let action)))):
            switch action {
            case .showPremiumClub:
                return .send(.delegate(.showPremiumClubPinned))
            }

        case .path(.element(_, .delegate(let action))):
            switch action {
            case .showPremiumClubPinned:
                return .send(.delegate(.showPremiumClubPinned))
            case .showLectorSchedule(let employee):
                state.path.append(.lector(.init(lector: employee)))
                return .none
            case .showGroupSchedule(let groupName):
                state.path.append(.group(.init(groupName: groupName)))
                return .none
            }

        case .search, .pinned, .favorites, .lectors, .loading, .delegate, .path:
            return .none
        }
    }

    private func filteredLecturers(state: inout State) {
        state.$lecturers = state.$loadedLecturers
            .map { lecturers in
                IdentifiedArray(
                    uniqueElements: lecturers
                        .filter(state.search.matches(lector:))
                        .map(LecturersRow.State.init(lector:))
                )
            }
    }

    private func filteredFavorites(state: inout State) {
        state.favorites = IdentifiedArray(
            uniqueElements: state.favoriteIds.compactMap({ state.lecturers?[id: $0] })
        )
    }

    private func filteredPinned(state: inout State) {
        state.pinned = state.pinnedLector.flatMap { state.lecturers?[id: $0.id] }
    }

    private func listenToFavoriteUpdates() -> Effect<Action> {
        return .run { send in
            for await value in favorites.lecturerIds.values {
                await send(._favoritesUpdate(value), animation: .default)
            }
        }
    }

    private func listenToPinnedUpdates() -> Effect<Action> {
        return .run { send in
            for await value in pinnedSchedule().map(\.?.lector).removeDuplicates().values {
                await send(._pinnedUpdate(value), animation: .default)
            }
        }
    }
}

// MARK: - Matching

private extension LecturersSearch.State {
    func matches(lector: Employee) -> Bool {
        guard !query.isEmpty else { return true }
        return lector.fio.localizedCaseInsensitiveContains(query)
    }
}
