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

public struct GroupsFeature: ReducerProtocol {
    public struct State: Equatable {
        @LoadableState var sections: IdentifiedArrayOf<GroupsSection.State>?
        var search: GroupsSearch.State = .init()
        var isOnTop: Bool = true
        @PresentationState var groupSchedule: GroupScheduleFeature.State?

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
            case showPremiumClubFakeAdsBanner
        }

        case groupSchedule(PresentationAction<GroupScheduleFeature.Action>)
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
    
    public var body: some ReducerProtocolOf<Self> {
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
                groupTapped(rowId: rowId, in: \.sections?[id: sectionId], state: &state)
                return .none

            case let .pinned(.groupRow(rowId, .rowTapped)):
                groupTapped(rowId: rowId, in: \.pinned, state: &state)
                return .none

            case let .favorites(.groupRow(rowId, .rowTapped)):
                groupTapped(rowId: rowId, in: \.favorites, state: &state)
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

            case .groupSchedule(.presented(.delegate(let action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showPremiumClubFakeAdsBanner:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case .groupSchedule, .pinned, .favorites, .search, .groupSection, .loading, .delegate:
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
        .load(\.$loadedGroups) { _, isRefresh in try await apiClient.groups(ignoreCache: isRefresh) }
        .ifLet(\.$groupSchedule, action: /Action.groupSchedule) {
            GroupScheduleFeature()
        }

        Scope(state: \.search, action: /Action.search) {
            GroupsSearch()
        }
    }

    private func groupTapped(rowId: String, in keyPath: KeyPath<State, GroupsSection.State?>, state: inout State) {
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
                await send(._favoritesUpdate(value), animation: .default)
            }
        }
    }

    private func listenToPinnedUpdates() -> EffectTask<Action> {
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
