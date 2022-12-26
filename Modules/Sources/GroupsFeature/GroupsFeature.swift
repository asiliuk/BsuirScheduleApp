import Foundation
import SwiftUI
import BsuirApi
import BsuirCore
import EntityScheduleFeature
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import Favorites
import ScheduleFeature
import Collections
import IdentifiedCollections
import os.log

enum StrudentGroupSearchToken: Hashable, Identifiable {
    var id: Self { self }

    case faculty(String)
    case speciality(String)
    case course(Int?)
}

public struct GroupsFeature: ReducerProtocol {
    public struct State: Equatable {
        @LoadableState var sections: IdentifiedArrayOf<GroupSection.State>?
        var search: GroupSearch.State = .init()
        var isOnTop: Bool = true
        var groupSchedule: GroupScheduleFeature.State?

        fileprivate(set) var pinned: GroupSection.State? = {
            @Dependency(\.favorites.currentPinnedSchedule) var pinned
            return (pinned?.groupName).flatMap(GroupSection.State.pinned)
        }()

        fileprivate(set) var favorites: GroupSection.State? = {
            @Dependency(\.favorites.currentGroupNames) var favorites
            return .favorites(Array(favorites))
        }()

        @LoadableState var loadedGroups: [StudentGroup]?
        
        public init() {}
    }
    
    public enum Action: Equatable, FeatureAction, LoadableAction {
        public enum ViewAction: Equatable {
            case task
            case setIsOnTop(Bool)
            case setGroupSchedule(GroupScheduleFeature.State?)
        }
        
        public enum ReducerAction: Equatable {
            case favoritesUpdate(OrderedSet<String>)
            case pinnedUpdate(String?)
            case groupSchedule(GroupScheduleFeature.Action)
            case pinned(GroupSection.Action)
            case favorites(GroupSection.Action)
            case search(GroupSearch.Action)
        }

        public typealias DelegateAction = Never
        
        case loading(LoadingAction<State>)
        case groupSection(id: GroupSection.State.ID, action: GroupSection.Action)
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
                return .merge(
                    listenToFavoriteUpdates(),
                    listenToPinnedUpdates()
                )

            case .view(.setIsOnTop(let value)):
                state.isOnTop = value
                return .none

            case .view(.setGroupSchedule(let value)):
                state.groupSchedule = value
                return .none

            case let .groupSection(sectionId, action: .groupRow(rowId, action: .rowTapped)):
                groupTapped(rowId: rowId, in: \.sections?[id: sectionId], state: &state)
                return .none

            case let .reducer(.pinned(.groupRow(rowId, .rowTapped))):
                groupTapped(rowId: rowId, in: \.pinned, state: &state)
                return .none

            case let .reducer(.favorites(.groupRow(rowId, .rowTapped))):
                groupTapped(rowId: rowId, in: \.favorites, state: &state)
                return .none
                
            case .loading(.started(\.$loadedGroups)),
                 .loading(.finished(\.$loadedGroups)):
                filteredGroups(state: &state)
                return .none
                
            case let .reducer(.favoritesUpdate(value)):
                state.favorites = .favorites(Array(value))
                return .none

            case let .reducer(.pinnedUpdate(value)):
                state.pinned = value.flatMap(GroupSection.State.pinned)
                return .none

            case .reducer(.search(.delegate(.didUpdateImportantState))):
                filteredGroups(state: &state)
                return .none

            case .reducer, .loading, .groupSection:
                return .none
            }
        }
        .ifLet(\.pinned, reducerAction: /Action.ReducerAction.pinned) {
            GroupSection()
        }
        .ifLet(\.favorites, reducerAction: /Action.ReducerAction.favorites) {
            GroupSection()
        }
        .ifLet(\.sections, action: /Action.groupSection) {
            EmptyReducer()
                .forEach(\.self, action: .self) { GroupSection() }
        }
        .load(\.$loadedGroups) { _, isRefresh in try await apiClient.groups(ignoreCache: isRefresh) }
        .ifLet(\.groupSchedule, reducerAction: /Action.ReducerAction.groupSchedule) {
            GroupScheduleFeature()
        }

        Scope(state: \.search, reducerAction: /Action.ReducerAction.search) {
            GroupSearch()
        }
    }

    private func groupTapped(rowId: String, in keyPath: KeyPath<State, GroupSection.State?>, state: inout State) {
        let groupName = state[keyPath: keyPath]?.groupRows[id: rowId]?.groupName
        state.groupSchedule = groupName.map(GroupScheduleFeature.State.init(groupName:))
    }
    
    private func filteredGroups(state: inout State) {
        state.$sections = state.$loadedGroups
            .map { groups in
                return groups
                    .lazy
                    .filter(state.search.matches(group:))
                    .makeSections()
            }

        state.search.updateSuggestedTokens(for: state.loadedGroups ?? [])
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

private extension Array where Element == StudentGroup {
    func makeSections() -> IdentifiedArrayOf<GroupSection.State> {
        let sections: [GroupSection.State] = Dictionary(grouping: self, by: { $0.name.prefix(3) })
            .sorted(by: { $0.key < $1.key })
            .compactMap { title, groups in
                GroupSection.State(
                    title: String(title),
                    groupNames: groups.map(\.name).sorted()
                )
            }

        return IdentifiedArray(uniqueElements: sections)
    }
}

// MARK: - GroupSection

private extension GroupSection.State {
    static func favorites(_ groupNames: [String]) -> Self? {
        return .init(title: String(localized: "screen.groups.favorites.section.header"), groupNames: groupNames)
    }

    static func pinned(_ groupName: String) -> Self? {
        return .init(title: String(localized: "screen.groups.pinned.section.header"), groupNames: [groupName])
    }
}

// MARK: - Reset

extension GroupsFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if groupSchedule != nil {
            return groupSchedule = nil
        }

        if search.reset() {
            return
        }

        if !isOnTop {
            return isOnTop = true
        }
    }

    /// Open shcedule screen for group.
    mutating public func openGroup(named name: String) {
        guard groupSchedule?.groupName != name else { return }
        search.reset()
        groupSchedule = GroupScheduleFeature.State(groupName: name)
    }
}
