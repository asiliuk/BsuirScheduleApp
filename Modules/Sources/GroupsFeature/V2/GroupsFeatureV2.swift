import Foundation
import ComposableArchitecture
import EntityScheduleFeature
import LoadableFeature

@Reducer
public struct GroupsFeatureV2 {
    @ObservableState
    public struct State {
        var path = StackState<EntityScheduleFeature.State>()
        var hasPinnedPlaceholder: Bool  = false
        var favoritesPlaceholderCount: Int = 0
        var groups: LoadingState<LoadedGroupsFeature.State> = .initial

        public init() {}
    }

    public enum Action {
        case onAppear

        case groups(LoadingActionOf<LoadedGroupsFeature>)
        case path(StackAction<EntityScheduleFeature.State, EntityScheduleFeature.Action>)
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

            case .groups, .path:
                return .none
            }
        }
        .load(state: \.groups, action: \.groups) { _, isRefresh in
            let groups = try await apiClient.groups(isRefresh)
            // TODO: !!! REMOVE THIS!!!
            try await Task.sleep(for: .seconds(5))
            return LoadedGroupsFeature.State(
                groups: groups,
                favoritesNames: favoriteGroupNames,
                pinnedName: pinnedSchedule()?.groupName
            )
        } loaded: {
            LoadedGroupsFeature()
        }
        .forEach(\.path, action: \.path) {
            EntityScheduleFeature()
        }
    }
}
