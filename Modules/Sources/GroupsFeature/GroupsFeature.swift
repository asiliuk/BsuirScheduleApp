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

@Reducer
public struct GroupsFeature {
    public struct State: Equatable {
        /// Designed to defer group presentation to the moment when component was presented
        enum GroupPresentationMode: Equatable {
            /// initial state, attempts to present group in this mode would end up deferred
            case initial
            /// deferred, means that there were attempt to present group before component appeared
            case deferred(String, displayType: ScheduleDisplayType)
            /// immediate, meaning component was presented and all attempts to present group should not be deferred
            case immediate
        }

        var groupPresentationMode: GroupPresentationMode = .initial

        var path = StackState<EntityScheduleFeature.State>()
        
        var favorites: GroupsSection.State?
        var pinned: GroupsSection.State?
        @LoadableState var sections: IdentifiedArrayOf<GroupsSection.State>?

        var search: GroupsSearch.State = .init()
        var isOnTop: Bool = true

        var hasPinnedPlaceholder: Bool { pinnedName != nil }

        fileprivate var pinnedName: String? = {
            @Dependency(\.pinnedScheduleService.currentSchedule) var pinnedSchedule
            return pinnedSchedule()?.groupName
        }()

        var favoritesPlaceholderCount: Int { favoriteNames.count }

        fileprivate var favoriteNames: OrderedSet<String> = {
            @Dependency(\.favorites.currentGroupNames) var favorites
            return favorites
        }()

        @LoadableState var loadedGroups: IdentifiedArray<String, StudentGroup>?

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
        case groupSections(IdentifiedActionOf<GroupsSection>)

        case task
        case setIsOnTop(Bool)

        case _favoritesUpdate(OrderedSet<String>)
        case _pinnedUpdate(String?)
        
        case loading(LoadingAction<State>)
        case delegate(DelegateAction)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites) var favorites
    @Dependency(\.pinnedScheduleService.schedule) var pinnedSchedule

    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                state.presentDeferredGroupIfNeeded()
                return .merge(
                    listenToFavoriteUpdates(),
                    listenToPinnedUpdates()
                )

            case .setIsOnTop(let value):
                state.isOnTop = value
                return .none

            case let .groupSections(.element(sectionId, action: .groupRows(.element(rowId, action: .rowTapped)))):
                let groupName = state.sections?[id: sectionId]?.groupRows[id: rowId]?.groupName
                state.presentGroup(groupName)
                return .none

            case let .pinned(.groupRows(.element(rowId, .rowTapped))):
                let groupName = state.pinned?.groupRows[id: rowId]?.groupName
                state.presentGroup(groupName)
                return .none

            case let .favorites(.groupRows(.element(rowId, .rowTapped))):
                let groupName = state.favorites?.groupRows[id: rowId]?.groupName
                state.presentGroup(groupName)
                return .none

            case .loading(.started(\.$loadedGroups)),
                 .loading(.finished(\.$loadedGroups)):
                filteredGroups(state: &state)
                filteredFavorites(state: &state)
                filteredPinned(state: &state)
                return .none

            case let ._favoritesUpdate(value):
                state.favoriteNames = value
                filteredFavorites(state: &state)
                return .none

            case let ._pinnedUpdate(value):
                state.pinnedName = value
                filteredPinned(state: &state)
                return .none

            case .search(.delegate(.didUpdateImportantState)):
                filteredGroups(state: &state)
                filteredFavorites(state: &state)
                filteredPinned(state: &state)
                return .none

            case .pinned(.groupRows(.element(_, .mark(.delegate(let action))))),
                    .favorites(.groupRows(.element(_, .mark(.delegate(let action))))),
                    .groupSections(.element(_, .groupRows(.element(_, .mark(.delegate(let action)))))):
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

            case .pinned, .favorites, .search, .groupSections, .loading, .delegate, .path:
                return .none
            }
        }
        .ifLet(\.pinned, action: \.pinned) {
            GroupsSection()
        }
        .ifLet(\.favorites, action: \.favorites) {
            GroupsSection()
        }
        .ifLet(\.sections, action: \.groupSections) {
            EmptyReducer()
                .forEach(\.self, action: \.self) {
                    GroupsSection()
                }
        }
        .load(\.$loadedGroups) { _, isRefresh in 
            try await IdentifiedArray(uniqueElements: apiClient.groups(isRefresh), id: \.name)
        }
        .forEach(\.path, action: \.path) {
            EntityScheduleFeature()
        }

        Scope(state: \.search, action: \.search) {
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

        state.search.updateSuggestedTokens(for: state.loadedGroups ?? .init(id: \.name))
    }

    private func filteredFavorites(state: inout State) {
        state.favorites = .favorites(
            state.favoriteNames
                .compactMap { state.loadedGroups?[id: $0] }
                .filter(state.search.matches(group:))
                .map(\.name)
        )
    }

    private func filteredPinned(state: inout State) {
        state.pinned = state.pinnedName
            .flatMap { state.loadedGroups?[id: $0] }
            .flatMap { state.search.matches(group: $0) ? $0 : nil }
            .flatMap { .pinned($0.name) }
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
            for await value in pinnedSchedule().map(\.?.groupName).removeDuplicates().values {
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

// MARK: - Matching

private extension GroupsSearch.State {
    func matches(group: StudentGroup) -> Bool {
        guard tokens.matches(group: group) else { return false }
        guard !query.isEmpty else { return true }
        return group.name.localizedCaseInsensitiveContains(query)
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

// MARK: - GroupsSection

private extension GroupsSection.State {
    static func favorites(_ groupNames: [String]) -> Self? {
        return .init(title: String(localized: "screen.groups.favorites.section.header"), groupNames: groupNames)
    }

    static func pinned(_ groupName: String) -> Self? {
        return .init(title: String(localized: "screen.groups.pinned.section.header"), groupNames: [groupName])
    }
}
