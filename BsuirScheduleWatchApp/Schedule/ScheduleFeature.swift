import Foundation
import ComposableArchitecture
import ScheduleCore
import LoadableFeature
import BsuirApi

@Reducer
struct ScheduleFeature {
    @ObservableState
    struct State {
        var source: ScheduleSource
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
            try await LoadedScheduleFeature.State(
                source: state.source,
                response: apiClient.schedule(source: state.source, refresh: refresh)
            )
        } loaded: {
            LoadedScheduleFeature()
        }
    }
}
