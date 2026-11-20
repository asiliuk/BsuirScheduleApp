import Foundation
import ComposableArchitecture
import BsuirApi
import LoadableFeature

@Reducer
struct GroupsFeature {
    @ObservableState
    struct State {
        // MARK: Groups
        var groups: LoadingState<LoadedGroupsFeature.State> = .initial
    }

    enum Action {
        case groups(LoadingActionOf<LoadedGroupsFeature>)
    }

    @Dependency(\.apiClient) var apiClient

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
        .load(state: \.groups, action: \.groups) { _, isRefresh in
            let groups = try await apiClient.groups(isRefresh)
            return LoadedGroupsFeature.State(groups: groups)
        } loaded: {
            LoadedGroupsFeature()
        }
    }
}
