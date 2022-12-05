import Foundation
import BsuirApi
import BsuirCore
import EntityScheduleFeature
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Favorites
import ScheduleFeature
import Collections
import os.log

public struct GroupsFeature: ReducerProtocol {
    public struct State: Equatable {
        struct Section: Equatable, Identifiable {
            var id: String { title }
            let title: String
            let groups: [StudentGroup]
        }
        
        @BindableState var searchQuery: String = ""
        var dismissSearch: Bool = false
        @BindableState var isOnTop: Bool = true

        @BindableState var groupSchedule: GroupScheduleFeature.State?

        var favorites: [String] = []
        @LoadableState var sections: [Section]?
        @LoadableState var loadedGroups: [StudentGroup]?
        
        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction, BindableAction, LoadableAction {
        public enum ViewAction: Equatable {
            case task
            case groupTapped(name: String)
            case filterGroups
        }
        
        public enum ReducerAction: Equatable {
            case favoritesUpdate(OrderedSet<String>)
            case groupSchedule(GroupScheduleFeature.Action)
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
                
            case let .view(.groupTapped(name)):
                state.groupSchedule = .init(groupName: name)
                return .none
                
            case .view(.filterGroups):
                filteredGroups(state: &state)
                return .none
                
            case .loading(.started(\.$loadedGroups)),
                 .loading(.finished(\.$loadedGroups)):
                filteredGroups(state: &state)
                return .none
                
            case let .reducer(.favoritesUpdate(value)):
                state.favorites = Array(value)
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
        .load(\.$loadedGroups) { _, isRefresh in try await apiClient.groups(ignoreCache: isRefresh) }
        .ifLet(\.groupSchedule, action: (/Action.reducer).appending(path: /Action.ReducerAction.groupSchedule)) {
            GroupScheduleFeature()
        }
        
        BindingReducer()
    }
    
    private func filteredGroups(state: inout State) {
        state.$sections = state.$loadedGroups
            .map { groups in
                guard !state.searchQuery.isEmpty else { return groups.makeSections() }
                return groups
                    .lazy
                    .filter { $0.name.localizedCaseInsensitiveContains(state.searchQuery) }
                    .makeSections()
            }
    }
    
    private func listenToFavoriteUpdates() -> EffectTask<Action> {
        return .run { send in
            for await value in favorites.groupNames.values {
                await send(.reducer(.favoritesUpdate(value)), animation: .default)
            }
        }
    }
}

private extension Array where Element == StudentGroup {
    func makeSections() -> [GroupsFeature.State.Section] {
        return Dictionary(grouping: self, by: { $0.name.prefix(3) })
            .sorted(by: { $0.key < $1.key })
            .map { title, groups in
                .init(
                    title: String(title),
                    groups: groups.sorted { $0.name < $1.name }
                )
            }
    }
}

// MARK: - Reset

extension GroupsFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if groupSchedule != nil {
            return groupSchedule = nil
        }

        if !searchQuery.isEmpty {
            return dismissSearch = true
        }

        if !isOnTop {
            return isOnTop = true
        }
    }

    /// Open shcedule screen for group.
    mutating public func openGroup(named name: String) {
        guard groupSchedule?.groupName != name else { return }
        dismissSearch = true
        groupSchedule = GroupScheduleFeature.State(groupName: name)
    }
}
