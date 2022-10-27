import Foundation
import BsuirApi
import BsuirCore
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Favorites

public struct LecturersFeature: ReducerProtocol {
    public struct State: Equatable {
        @BindableState var searchQuery: String = ""
        @BindableState var selectedLector: Employee?
        var favorites: [Employee] = []
        var lecturers: LodableContentState<[Employee]> = .initial
        fileprivate var loadedLecturers = LoadableFeature<[Employee]>.State()
        
        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction, BindableAction {
        public enum ViewAction: Equatable {
            case task
            case lecturerTapped(Employee)
            case filterLecturers
        }
        
        public enum ReducerAction: Equatable {
            case loadableLecturers(LoadableFeature<[Employee]>.Action)
            case favoritesUpdate([Employee])
        }
        
        public typealias DelegateAction = Never
        
        case binding(BindingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.requestsManager) var requestsManager
    @Dependency(\.favorites) var favorites

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.loadedLecturers, action: /Action.ReducerAction.loadableLecturers) {
            LoadableFeature.loadLecturers(requestsManager)
        }
        
        Reduce { state, action in
            switch action {
            case .view(.task):
                return listenToFavoriteUpdates()
                
            case let .view(.lecturerTapped(lector)):
                state.selectedLector = lector
                return .none
                
            case .view(.filterLecturers):
                filteredLecturers(state: &state)
                return .none
                
            case .reducer(.loadableLecturers):
                filteredLecturers(state: &state)
                return .none
                
            case let .reducer(.favoritesUpdate(value)):
                state.favorites = value
                return .none
                
            case .reducer, .binding:
                return .none
            }
        }
        
        BindingReducer()
    }
    
    private func filteredLecturers(state: inout State) {
        guard !state.searchQuery.isEmpty else {
            state.lecturers = state.loadedLecturers
            return
        }

        state.lecturers = state.loadedLecturers
            .map { $0.filter { $0.fio.localizedCaseInsensitiveContains(state.searchQuery) } }
    }
    
    private func listenToFavoriteUpdates() -> EffectTask<Action> {
        return .run { send in
            for await value in favorites.lecturers.values {
                await send(.reducer(.favoritesUpdate(value)), animation: .default)
            }
        }
    }
}

private extension LoadableFeature where Value == [Employee] {
    static func loadLecturers(_ requestsManager: RequestsManager) -> Self {
        return LoadableFeature {
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
}
