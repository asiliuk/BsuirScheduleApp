import Foundation
import ComposableArchitecture
import BsuirApi
import LoadableFeature
import ScheduleCore

@Reducer
struct LecturersFeature {
    @ObservableState
    struct State {
        var lecturers: LoadingState<LoadedLecturersFeature.State> = .initial
        var path = StackState<ScheduleFeature.State>()
    }

    enum Action {
        case lecturers(LoadingActionOf<LoadedLecturersFeature>)
        case path(StackActionOf<ScheduleFeature>)
    }

    @Dependency(\.apiClient) var apiClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .lecturers(.loaded(.delegate(let action))):
                switch action {
                case .showLecturerSchedule(let lecturer):
                    state.path.append(ScheduleFeature.State(source: .lector(lecturer)))
                    return .none
                }
            case .path, .lecturers:
                return .none
            }
        }
        .load(state: \.lecturers, action: \.lecturers) { _, isRefresh in
            let lecturers = try await apiClient.lecturers(isRefresh)
            return LoadedLecturersFeature.State(lecturers: lecturers)
        } loaded: {
            LoadedLecturersFeature()
        }
        .forEach(\.path, action: \.path) {
            ScheduleFeature()
        }
    }
}
