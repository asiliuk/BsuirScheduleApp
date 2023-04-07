import Foundation
import BsuirApi
import BsuirCore
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture
import Favorites
import Collections

public struct LecturersFeature: Reducer {
    public struct State: Equatable {
        var search: LecturersSearch.State = .init()
        @LoadableState var lecturers: IdentifiedArrayOf<LecturersRow.State>?
        fileprivate(set) var isOnTop: Bool = true
        fileprivate(set) var lectorSchedule: LectorScheduleFeature.State?

        var favorites: IdentifiedArrayOf<LecturersRow.State>? {
            get {
                guard
                    let favorites = lecturers?.filter({ favoriteIds.contains($0.id) }),
                    !favorites.isEmpty
                else { return nil }
                return favorites
            }
            set {
                favoriteIds = newValue?.ids ?? []
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
        fileprivate var lectorIdToOpen: Int?

        public init() {}
    }
    
    public enum Action: Equatable, LoadableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
            case showPremiumClubFakeAdsBanner
        }

        case lectorSchedule(LectorScheduleFeature.Action)
        case search(LecturersSearch.Action)
        case pinned(LecturersRow.Action)
        case favorite(id: LecturersRow.State.ID, action: LecturersRow.Action)
        case lector(id: LecturersRow.State.ID, action: LecturersRow.Action)

        case task
        case setIsOnTop(Bool)
        case setLectorScheduleId(Int?)
        
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
        .ifLet(\.favorites, action: /Action.favorite) {
            EmptyReducer<IdentifiedArrayOf<LecturersRow.State>, _>()
                .forEach(\.self, action: .self) {
                    LecturersRow()
                }
        }
        .ifLet(\.lecturers, action: /Action.lector) {
            EmptyReducer<IdentifiedArrayOf<LecturersRow.State>, _>()
                .forEach(\.self, action: .self) {
                    LecturersRow()
                }
        }
        .load(\.$loadedLecturers) { _, isRefresh in
            try await IdentifiedArray(uniqueElements: apiClient.lecturers(ignoreCache: isRefresh))
        }
        .ifLet(\.lectorSchedule, action: /Action.lectorSchedule) {
            LectorScheduleFeature()
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

        case .setLectorScheduleId(nil):
            state.lectorSchedule = nil
            return .none

        case .setLectorScheduleId(.some):
            assertionFailure("Not really expecting this to happen")
            return .none

        case .pinned(.rowTapped):
            let lector = state.pinned?.lector
            state.lectorSchedule = lector.map(LectorScheduleFeature.State.init(lector:))
            return .none

        case let .favorite(id, .rowTapped):
            let lector = state.favorites?[id: id]?.lector
            state.lectorSchedule = lector.map(LectorScheduleFeature.State.init(lector:))
            return .none

        case let .lector(id, .rowTapped):
            let lector = state.loadedLecturers?[id: id]
            state.lectorSchedule = lector.map(LectorScheduleFeature.State.init(lector:))
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

        case .lectorSchedule(.delegate(let action)):
            switch action {
            case .showPremiumClubPinned:
                return .send(.delegate(.showPremiumClubPinned))
            case .showPremiumClubFakeAdsBanner:
                return .send(.delegate(.showPremiumClubFakeAdsBanner))
            }

        case .lectorSchedule, .search, .pinned, .favorite, .lector, .loading, .delegate:
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
        if lectorSchedule != nil {
            return lectorSchedule = nil
        }

        if search.reset() {
            return
        }

        if !isOnTop {
            return isOnTop = true
        }
    }

    /// Open shcedule screen for lector.
    public mutating func openLector(_ lector: Employee) {
        guard lectorSchedule?.lector != lector else { return }

        search.reset()
        lectorSchedule = LectorScheduleFeature.State(lector: lector)
        lectorIdToOpen = nil
    }

    /// Open shcedule screen for lector.
    public mutating func openLector(id: Int) {
        if let lector = loadedLecturers?[id: id] {
            openLector(lector)
        } else {
            lectorIdToOpen = id
        }
    }

    /// Check if we have model for lecror we were trying to open if so open its schedule.
    fileprivate mutating func openLectorIfNeeded() {
        guard let lectorIdToOpen else { return }
        openLector(id: lectorIdToOpen)
    }
}
