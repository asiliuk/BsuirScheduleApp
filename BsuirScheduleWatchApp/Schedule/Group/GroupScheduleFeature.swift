import ComposableArchitecture
import BsuirApi
import ScheduleCore
import LoadableFeature

@Reducer
struct GroupScheduleFeature {
    @ObservableState
    struct State {
        var name: String
        var schedule: LoadingState<LoadedScheduleFeature.State> = .initial
    }

    enum Action {
        case schedule(LoadingActionOf<LoadedScheduleFeature>)
    }

    @Dependency(\.apiClient) var apiClient

    var body: some Reducer<State, Action> {
        Reduce { _, _ in
            .none
        }
        .load(state: \.schedule, action: \.schedule) { state, refresh in
            let groupSchedule = try await apiClient.groupSchedule(state.name, refresh)
            let response = ScheduleRequestResponse(response: groupSchedule)
            return LoadedScheduleFeature.State(response: response)
        }
    }
}

