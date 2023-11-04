import Foundation
import BsuirApi
import BsuirCore
import LoadableFeature
import EntityScheduleFeature
import ScheduleFeature
import ComposableArchitecture
import Favorites
import Collections

public struct LecturersFeature: Reducer {
    public struct State: Equatable {
        var path = StackState<EntityScheduleFeature.State>()
        var search: LecturersSearch.State = .init()
        @LoadableState var lecturers: IdentifiedArrayOf<LecturersRow.State>?
        fileprivate(set) var isOnTop: Bool = true

        var favorites: IdentifiedArrayOf<LecturersRow.State> {
            get {
                IdentifiedArray(uniqueElements: favoriteIds.compactMap({ lecturers?[id: $0] }))
            }
            set {
                favoriteIds = newValue.ids
            }
        }

        var pinned: LecturersRow.State? = {
            @Dependency(\.favorites.currentPinnedSchedule) var pinned
            return (pinned?.lector).map(LecturersRow.State.init(lector:))
        }()

        var favoriteIds: OrderedSet<Int> = {
            @Dependency(\.favorites.currentLectorIds) var currentLectorIds
            return currentLectorIds
        }()

        @LoadableState var loadedLecturers: IdentifiedArrayOf<Employee>?

        // When deeplink was opened but no lecturers yet loaded
        fileprivate struct LectorScheduleDeferredDetails: Equatable {
            let id: Int
            let displayType: ScheduleDisplayType
        }
        fileprivate var lectorToOpen: LectorScheduleDeferredDetails?

        public init() {}
    }
    
    public enum Action: Equatable, LoadableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
        }

        case path(StackAction<EntityScheduleFeature.State, EntityScheduleFeature.Action>)
        case search(LecturersSearch.Action)
        case pinned(LecturersRow.Action)
        case favorite(id: LecturersRow.State.ID, action: LecturersRow.Action)
        case lector(id: LecturersRow.State.ID, action: LecturersRow.Action)

        case task
        case setIsOnTop(Bool)
        
        case _favoritesUpdate(OrderedSet<Int>)
        case _pinnedUpdate(Employee?)

        case loading(LoadingAction<State>)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites) var favorites

    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { coreReduce(into: &$0, action: $1) }
        .ifLet(\.pinned, action: /Action.pinned) {
            LecturersRow()
        }
        .forEach(\.favorites, action: /Action.favorite) {
            LecturersRow()

        }
        .ifLet(\.lecturers, action: /Action.lector) {
            EmptyReducer<IdentifiedArrayOf<LecturersRow.State>, _>()
                .forEach(\.self, action: .self) {
                    LecturersRow()
                }
        }
        .load(\.$loadedLecturers) { _, isRefresh in
            try await IdentifiedArray(uniqueElements: apiClient.lecturers(isRefresh))
        }
        .forEach(\.path, action: /Action.path) {
            EntityScheduleFeature()
        }

        Scope(state: \.search, action: /Action.search) {
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

        case let .favorite(id, .rowTapped):
            let lector = state.favorites[id: id]?.lector
            state.presentLector(lector)
            return .none

        case let .lector(id, .rowTapped):
            let lector = state.loadedLecturers?[id: id]
            state.presentLector(lector)
            return .none

        case .loading(.started(\.$loadedLecturers)):
            filteredLecturers(state: &state)
            return .none

        case .loading(.finished(\.$loadedLecturers)):
            filteredLecturers(state: &state)
            state.openLectorIfNeeded()
            return .none

        case .search(.delegate(.didUpdateImportantState)):
            filteredLecturers(state: &state)
            return .none

        case let ._favoritesUpdate(value):
            state.favoriteIds = value
            return .none

        case let ._pinnedUpdate(value):
            state.pinned = value.map(LecturersRow.State.init(lector:))
            return .none

        case .favorite(_, .mark(.delegate(let action))),
             .lector(_, .mark(.delegate(let action))):
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

        case .search, .pinned, .favorite, .lector, .loading, .delegate, .path:
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
    
    private func listenToFavoriteUpdates() -> Effect<Action> {
        return .run { send in
            for await value in favorites.lecturerIds.values {
                await send(._favoritesUpdate(value), animation: .default)
            }
        }
    }

    private func listenToPinnedUpdates() -> Effect<Action> {
        return .run { send in
            for await value in favorites.pinnedSchedule.map(\.?.lector).removeDuplicates().values {
                await send(._pinnedUpdate(value), animation: .default)
            }
        }
    }
}

// MARK: - Reset

extension LecturersFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if !path.isEmpty {
            return path = StackState()
        }

        if search.reset() {
            return
        }

        if !isOnTop {
            return isOnTop = true
        }
    }

    /// Open schedule screen for lector.
    public mutating func openLector(_ lector: Employee, displayType: ScheduleDisplayType) {
        if path.count == 1,
           let id = path.ids.last,
           case let .lector(state) = path.last,
           state.lector == lector
        {
            path[id: id, case: /EntityScheduleFeature.State.lector]?.schedule.switchDisplayType(displayType)
            return
        }
        search.reset()
        presentLector(lector, displayType: displayType)
        lectorToOpen = nil
    }

    /// Open schedule screen for lector.
    public mutating func openLector(id: Int, displayType: ScheduleDisplayType = .continuous) {
        if let lector = loadedLecturers?[id: id] {
            openLector(lector, displayType: displayType)
        } else {
            lectorToOpen = .init(id: id, displayType: displayType)
        }
    }

    /// Check if we have model for lector we were trying to open if so open its schedule.
    fileprivate mutating func openLectorIfNeeded() {
        guard let lectorToOpen else { return }
        openLector(id: lectorToOpen.id, displayType: lectorToOpen.displayType)
    }

    fileprivate mutating func presentLector(_ lector: Employee?, displayType: ScheduleDisplayType = .continuous) {
        guard let lector else { return }
        path = StackState([.lector(.init(lector: lector, scheduleDisplayType: displayType))])
    }
}
