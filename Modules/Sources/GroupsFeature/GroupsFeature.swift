import Foundation
import BsuirApi
import BsuirCore
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Favorites

public struct GroupsFeature: ReducerProtocol {
    public struct State: Equatable {
        struct Section: Equatable, Identifiable {
            var id: String { title }
            let title: String
            let groups: [StudentGroup]
        }
        
        @BindableState var searchQuery: String = ""
        @BindableState var selectedGroup: StudentGroup?
        var favorites: [StudentGroup] = []
        @LoadableState var sections: [Section]?
        @LoadableState var loadedGroups: [StudentGroup]?
        
        public init() {}
    }
    
    public enum Action: FeatureAction, BindableAction, LoadableAction {
        public enum ViewAction: Equatable {
            case task
            case groupTapped(StudentGroup)
            case filterGroups
        }
        
        public enum ReducerAction: Equatable {
            case favoritesUpdate([StudentGroup])
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
                
            case let .view(.groupTapped(group)):
                state.selectedGroup = group
                return .none
                
            case .view(.filterGroups):
                filteredGroups(state: &state)
                return .none
                
            case .loading(.finished(\.$loadedGroups)):
                filteredGroups(state: &state)
                return .none
                
            case let .reducer(.favoritesUpdate(value)):
                state.favorites = value
                return .none
                
            case .reducer, .binding, .loading:
                return .none
            }
        }
        .load(\.$loadedGroups, fetch: loadGroups)
        
        BindingReducer()
    }
    
    private func filteredGroups(state: inout State) {
        guard !state.searchQuery.isEmpty else {
            state.sections = state.loadedGroups.map(makeSections(groups:))
            return
        }
        
        state.sections = state.loadedGroups
            .map { $0.filter { $0.name.localizedCaseInsensitiveContains(state.searchQuery) } }
            .map(makeSections(groups:))
    }
    
    private func makeSections(groups: [StudentGroup]) -> [State.Section] {
        return Dictionary(grouping: groups, by: { $0.name.prefix(3) })
            .sorted(by: { $0.key < $1.key })
            .map { title, groups in
                State.Section(
                    title: String(title),
                    groups: groups.sorted { $0.name < $1.name }
                )
            }
    }
    
    private func listenToFavoriteUpdates() -> EffectTask<Action> {
        return .run { send in
            for await value in favorites.groups.values {
                await send(.reducer(.favoritesUpdate(value)), animation: .default)
            }
        }
    }
    
    private func loadGroups(_ state: State) -> EffectTask<TaskResult<[StudentGroup]>> {
        return .run { send in
            let request = requestsManager
                .request(BsuirIISTargets.StudentGroups())
                .removeDuplicates()
                .log(.appState, identifier: "All groups")

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
