import Foundation
import ComposableArchitecture
import BsuirApi
import LoadableFeature

@Reducer
struct GroupsFeature {
    @ObservableState
    struct State {
        var groups: LoadingState<LoadedGroupsFeature.State> = .initial
        var path = StackState<ScheduleFeature.State>()
    }

    enum Action {
        case groups(LoadingActionOf<LoadedGroupsFeature>)
        case path(StackActionOf<ScheduleFeature>)
    }

    @Dependency(\.apiClient) var apiClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .groups(.loaded(.delegate(let action))):
                switch action {
                case .showGroupSchedule(let name):
                    state.path.append(.group(GroupScheduleFeature.State(name: name)))
                    return .none
                }
            case .path, .groups:
                return .none
            }
        }
        .load(state: \.groups, action: \.groups) { _, isRefresh in
            let groups = try await apiClient.groups(isRefresh)
            return LoadedGroupsFeature.State(groups: groups)
        } loaded: {
            LoadedGroupsFeature()
        }
        .forEach(\.path, action: \.path)
    }
}
