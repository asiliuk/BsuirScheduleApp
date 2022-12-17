import Foundation
import BsuirApi
import BsuirCore
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Favorites
import Collections

public struct LecturersFeature: ReducerProtocol {
    public struct State: Equatable {
        @BindableState var searchQuery: String = ""
        var dismissSearch: Bool = false
        @BindableState var isOnTop: Bool = true

        @BindableState var lectorSchedule: LectorScheduleFeature.State?

        var favorites: IdentifiedArrayOf<Employee> { lecturers?.filter { favoriteIds.contains($0.id) } ?? [] }
        fileprivate(set) var favoriteIds: OrderedSet<Int> = {
            @Dependency(\.favorites.currentLectorIds) var currentLectorIds
            return currentLectorIds
        }()

        @LoadableState var lecturers: IdentifiedArrayOf<Employee>?
        @LoadableState var loadedLecturers: IdentifiedArrayOf<Employee>?

        // When deeplink was opened but no lecturers yet loaded
        fileprivate var lectorIdToOpen: Int?

        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction, BindableAction, LoadableAction {
        public enum ViewAction: Equatable {
            case task
            case lecturerTapped(Employee)
            case filterLecturers
        }
        
        public enum ReducerAction: Equatable {
            case favoritesUpdate(OrderedSet<Int>)
            case lectorSchedule(LectorScheduleFeature.Action)
        }
        
        public typealias DelegateAction = Never
        
        case binding(BindingAction<State>)
        case loading(LoadingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites) var favorites

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                return listenToFavoriteUpdates()
                
            case let .view(.lecturerTapped(lector)):
                state.lectorSchedule = .init(lector: lector)
                return .none
                
            case .view(.filterLecturers):
                filteredLecturers(state: &state)
                return .none
                
            case .loading(.started(\.$loadedLecturers)):
                filteredLecturers(state: &state)
                return .none

            case .loading(.finished(\.$loadedLecturers)):
                filteredLecturers(state: &state)
                state.openLectorIfNeeded()
                return .none
                
            case let .reducer(.favoritesUpdate(value)):
                state.favoriteIds = value
                return .none

            case .binding(\.$searchQuery):
                if state.searchQuery.isEmpty {
                    state.dismissSearch = false
                }
                return .none
                
            case .reducer, .binding, .loading:
                return .none
            }
        }
        .load(\.$loadedLecturers) { _, isRefresh in
            try await IdentifiedArray(uniqueElements: apiClient.lecturers(ignoreCache: isRefresh))
        }
        .ifLet(\.lectorSchedule, action: (/Action.reducer).appending(path: /Action.ReducerAction.lectorSchedule)) {
            LectorScheduleFeature()
        }
        
        BindingReducer()
    }
    
    private func filteredLecturers(state: inout State) {
        guard !state.searchQuery.isEmpty else {
            state.$lecturers = state.$loadedLecturers
            return
        }

        state.$lecturers = state.$loadedLecturers
            .map { $0.filter { $0.fio.localizedCaseInsensitiveContains(state.searchQuery) } }
    }
    
    private func listenToFavoriteUpdates() -> EffectTask<Action> {
        return .run { send in
            for await value in favorites.lecturerIds.values {
                await send(.reducer(.favoritesUpdate(value)), animation: .default)
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

        if !searchQuery.isEmpty {
            return dismissSearch = true
        }

        if !isOnTop {
            return isOnTop = true
        }
    }

    /// Open shcedule screen for lector.
    public mutating func openLector(_ lector: Employee) {
        guard lectorSchedule?.lector != lector else { return }

        dismissSearch = true
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
