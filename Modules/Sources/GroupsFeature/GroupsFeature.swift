import Foundation
import SwiftUI
import BsuirApi
import BsuirCore
import EntityScheduleFeature
import LoadableFeature
import ComposableArchitecture
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

public struct GroupsFeature: Reducer {
    public struct State: Equatable {
        var path = StackState<EntityScheduleFeature.State>()
        @LoadableState var sections: IdentifiedArrayOf<GroupsSection.State>?
        var search: GroupsSearch.State = .init()
        var isOnTop: Bool = true

        fileprivate(set) var pinned: GroupsSection.State? = {
            @Dependency(\.favorites.currentPinnedSchedule) var pinned
            return (pinned?.groupName).flatMap(GroupsSection.State.pinned)
        }()

        fileprivate(set) var favorites: GroupsSection.State? = {
            @Dependency(\.favorites.currentGroupNames) var favorites
            return .favorites(Array(favorites))
        }()

        @LoadableState var loadedGroups: [StudentGroup]?
        
        public init() {}
    }
    
    public enum Action: Equatable, LoadableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
        }

        case path(StackAction<EntityScheduleFeature.State, EntityScheduleFeature.Action>)
        case pinned(GroupsSection.Action)
        case favorites(GroupsSection.Action)
        case search(GroupsSearch.Action)
        case groupSection(id: GroupsSection.State.ID, action: GroupsSection.Action)

        case task
        case setIsOnTop(Bool)

        case _favoritesUpdate(OrderedSet<String>)
        case _pinnedUpdate(String?)
        
        case loading(LoadingAction<State>)
        case delegate(DelegateAction)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites) var favorites

    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .merge(
                    listenToFavoriteUpdates(),
                    listenToPinnedUpdates()
                )

            case .setIsOnTop(let value):
                state.isOnTop = value
                return .none

            case let .groupSection(sectionId, action: .groupRow(rowId, action: .rowTapped)):
                let groupName = state.sections?[id: sectionId]?.groupRows[id: rowId]?.groupName
                state.presentGroup(groupName)
                return .none

            case let .pinned(.groupRow(rowId, .rowTapped)):
                let groupName = state.pinned?.groupRows[id: rowId]?.groupName
                state.presentGroup(groupName)
                return .none

            case let .favorites(.groupRow(rowId, .rowTapped)):
                let groupName = state.favorites?.groupRows[id: rowId]?.groupName
                state.presentGroup(groupName)
                return .none

            case .loading(.started(\.$loadedGroups)),
                 .loading(.finished(\.$loadedGroups)):
                filteredGroups(state: &state)
                return .none

            case let ._favoritesUpdate(value):
                state.favorites = .favorites(Array(value))
                return .none

            case let ._pinnedUpdate(value):
                state.pinned = value.flatMap(GroupsSection.State.pinned)
                return .none

            case .search(.delegate(.didUpdateImportantState)):
                filteredGroups(state: &state)
                return .none

            case .pinned(.groupRow(_, .mark(.delegate(let action)))),
                 .favorites(.groupRow(_, .mark(.delegate(let action)))),
                 .groupSection(_, .groupRow(_, action: .mark(.delegate(let action)))):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClubPinned))
                }

            case .path(.element(_ , action: .delegate(let action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showLectorSchedule(let employee):
                    state.path.append(.lector(.init(lector: employee)))
                    return .none
                case .showGroupSchedule(let name):
                    state.path.append(.group(.init(groupName: name)))
                    return .none
                }

            case .pinned, .favorites, .search, .groupSection, .loading, .delegate, .path:
                return .none
            }
        }
        .ifLet(\.pinned, action: /Action.pinned) {
            GroupsSection()
        }
        .ifLet(\.favorites, action: /Action.favorites) {
            GroupsSection()
        }
        .ifLet(\.sections, action: /Action.groupSection) {
            EmptyReducer<IdentifiedArrayOf<GroupsSection.State>, _>()
                .forEach(\.self, action: .self) {
                    GroupsSection()
                }
        }
        .load(\.$loadedGroups) { _, isRefresh in try await apiClient.groups(isRefresh) }
        .forEach(\.path, action: /Action.path) {
            EntityScheduleFeature()
        }

        Scope(state: \.search, action: /Action.search) {
            GroupsSearch()
        }
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
    
    private func listenToFavoriteUpdates() -> Effect<Action> {
        return .run { send in
            for await value in favorites.groupNames.values {
                await send(._favoritesUpdate(value), animation: .default)
            }
        }
    }

    private func listenToPinnedUpdates() -> Effect<Action> {
        return .run { send in
            for await value in favorites.pinnedSchedule.map(\.?.groupName).removeDuplicates().values {
                await send(._pinnedUpdate(value), animation: .default)
            }
        }
    }
}

private extension Array where Element == StudentGroup {
    func makeSections() -> IdentifiedArrayOf<GroupsSection.State> {
        let sections: [GroupsSection.State] = Dictionary(grouping: self, by: { $0.name.prefix(3) })
            .sorted(by: { $0.key < $1.key })
            .compactMap { title, groups in
                GroupsSection.State(
                    title: String(title),
                    groupNames: groups.map(\.name).sorted()
                )
            }

        return IdentifiedArray(uniqueElements: sections)
    }
}

// MARK: - GroupsSection

private extension GroupsSection.State {
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

    /// Open shcedule screen for group.
    mutating public func openGroup(named name: String) {
        if path.count == 1,
           case let .group(state) = path.last,
           state.groupName == name
        { return }
        search.reset()
        presentGroup(name)
    }

    fileprivate mutating func presentGroup(_ groupName: String?) {
        guard let groupName else { return }
        path = StackState([.group(.init(groupName: groupName))])
    }
}
