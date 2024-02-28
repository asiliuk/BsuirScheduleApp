import Foundation
import ComposableArchitecture
import EntityScheduleFeature
import LoadableFeature

@Reducer
public struct GroupsFeatureV2 {
    @ObservableState
    public struct State {
        var path = StackState<EntityScheduleFeatureV2.State>()
        var search: GroupsSearch.State = .init()

        // Placeholder
        var hasPinnedPlaceholder: Bool  = false
        var favoritesPlaceholderCount: Int = 0

        // Groups
        var groups: LoadingState<LoadedGroupsFeature.State> = .initial

        public init() {}
    }

    public enum Action {
        case onAppear

        case groups(LoadingActionOf<LoadedGroupsFeature>)
        case path(StackAction<EntityScheduleFeatureV2.State, EntityScheduleFeatureV2.Action>)
        case search(GroupsSearch.Action)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites.currentGroupNames) var favoriteGroupNames
    @Dependency(\.pinnedScheduleService.currentSchedule) var pinnedSchedule

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.hasPinnedPlaceholder = pinnedSchedule()?.groupName != nil
                state.favoritesPlaceholderCount = favoriteGroupNames.count
                return .none

            case .search(.delegate(let action)):
                switch action {
                case .didUpdateImportantState:
                    return .none
                }

            case .groups(.loaded(.groupRows(.element(let groupName, action: .rowTapped)))):
                state.presentGroup(groupName)
                return .none

            case .groups, .path, .search:
                return .none
            }
        }
        .load(state: \.groups, action: \.groups) { _, isRefresh in
            let groups = try await apiClient.groups(isRefresh)
            // TODO: !!! REMOVE THIS!!!
            try await Task.sleep(for: .seconds(1))
            return LoadedGroupsFeature.State(
                groups: groups,
                favoritesNames: favoriteGroupNames,
                pinnedName: pinnedSchedule()?.groupName
            )
        } loaded: {
            LoadedGroupsFeature()
        }
        .forEach(\.path, action: \.path)

        Scope(state: \.search, action: \.search) {
            GroupsSearch()
        }
    }
}
