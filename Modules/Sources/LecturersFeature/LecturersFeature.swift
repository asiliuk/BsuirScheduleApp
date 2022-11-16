import Foundation
import BsuirApi
import BsuirCore
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Favorites

public struct LecturersFeature: ReducerProtocol {
    public struct State: Equatable {
        @BindableState var searchQuery: String = ""
        @BindableState var lectorSchedule: LectorScheduleFeature.State?
        var favorites: [Employee] = []
        @LoadableState var lecturers: [Employee]?
        @LoadableState var loadedLecturers: [Employee]?
        
        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction, BindableAction, LoadableAction {
        public enum ViewAction: Equatable {
            case task
            case lecturerTapped(Employee)
            case filterLecturers
        }
        
        public enum ReducerAction: Equatable {
            case favoritesUpdate([Employee])
            case lectorSchedule(LectorScheduleFeature.Action)
        }
        
        public typealias DelegateAction = Never
        
        case binding(BindingAction<State>)
        case loading(LoadingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.requestsManager) var requestsManager
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
                
            case .loading(.finished(\.$loadedLecturers)):
                filteredLecturers(state: &state)
                return .none
                
            case let .reducer(.favoritesUpdate(value)):
                state.favorites = value
                return .none
                
            case .reducer, .binding, .loading:
                return .none
            }
        }
        .load(\.$loadedLecturers, fetch: fetchLecturers)
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
            for await value in favorites.lecturers.values {
                await send(.reducer(.favoritesUpdate(value)), animation: .default)
            }
        }
    }
    
    private func fetchLecturers(_ state: State) -> EffectTask<TaskResult<[Employee]>> {
        return .run { send in
            let request = requestsManager
                .request(BsuirIISTargets.Employees())
                .removeDuplicates()
                .log(.appState, identifier: "All lecturers")

            do {
                for try await value in request.values {
                    await send(.success(value))
                }
            } catch {
                await send(.failure(error))
            }
        }
    }
}
