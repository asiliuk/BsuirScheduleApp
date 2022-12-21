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

enum StrudentGroupSearchToken: Hashable, Identifiable {
    var id: Self { self }

    case faculty(String)
    case speciality(String)
    case course(Int?)
}

public struct GroupsFeature: ReducerProtocol {
    public struct State: Equatable {
        struct Section: Equatable, Identifiable {
            var id: String { title }
            let title: String
            let groups: [StudentGroup]
        }

        @BindableState var searchTokens: [StrudentGroupSearchToken] = []
        @BindableState var searchSuggestedTokens: [StrudentGroupSearchToken] = []
        @BindableState var searchQuery: String = ""
        var dismissSearch: Bool = false
        @BindableState var isOnTop: Bool = true

        @BindableState var groupSchedule: GroupScheduleFeature.State?

        fileprivate(set) var pinned: String?  = {
            @Dependency(\.favorites.currentPinnedSchedule) var pinned
            return pinned?.groupName
        }()

        fileprivate(set) var favorites: [String] = {
            @Dependency(\.favorites.currentGroupNames) var favorites
            return Array(favorites)
        }()

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
            case pinnedUpdate(String?)
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
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .view(.task):
                return .merge(
                    listenToFavoriteUpdates(),
                    listenToPinnedUpdates()
                )
                
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

            case let .reducer(.pinnedUpdate(value)):
                state.pinned = value
                return .none

            case .binding(\.$searchTokens):
                filteredGroups(state: &state)
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
    }
    
    private func filteredGroups(state: inout State) {
        state.$sections = state.$loadedGroups
            .map { groups in
                return groups
                    .lazy
                    .filter { group in
                        guard state.searchTokens.matches(group: group) else { return false }
                        guard !state.searchQuery.isEmpty else { return true }
                        return group.name.localizedCaseInsensitiveContains(state.searchQuery)
                    }
                    .makeSections()
            }

        updateSearchSuggestedTokens(state: &state)
    }

    private func updateSearchSuggestedTokens(state: inout State) {
        state.searchSuggestedTokens = {
            let groups = state.loadedGroups ?? []
            switch state.searchTokens.last {
            case nil:
                return groups
                    .map(\.faculty)
                    .uniqueSorted(by: <)
                    .map(StrudentGroupSearchToken.faculty)
            case let .faculty(value):
                return groups
                    .filter { $0.faculty == value }
                    .map(\.speciality)
                    .uniqueSorted(by: <)
                    .map(StrudentGroupSearchToken.speciality)
            case let .speciality(value):
                return groups
                    .filter { $0.speciality == value }
                    .map(\.course)
                    .uniqueSorted(by: { ($0 ?? 0) < ($1 ?? 0) })
                    .map(StrudentGroupSearchToken.course)
            case .course:
                return []
            }
        }()
    }
    
    private func listenToFavoriteUpdates() -> EffectTask<Action> {
        return .run { send in
            for await value in favorites.groupNames.values {
                await send(.reducer(.favoritesUpdate(value)), animation: .default)
            }
        }
    }

    private func listenToPinnedUpdates() -> EffectTask<Action> {
        return .run { send in
            for await value in favorites.pinnedSchedule.map(\.?.groupName).removeDuplicates().values {
                await send(.reducer(.pinnedUpdate(value)), animation: .default)
            }
        }
    }
}

private extension Array where Element == StrudentGroupSearchToken {
    func matches(group: StudentGroup) -> Bool {
        allSatisfy {
            switch $0 {
            case .faculty(group.faculty),
                 .speciality(group.speciality),
                 .course(group.course):
                return true
            case .faculty, .speciality, .course:
                return false
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
