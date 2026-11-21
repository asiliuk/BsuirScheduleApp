import ComposableArchitecture
import BsuirApi

@Reducer
struct GroupScheduleFeature {
    @ObservableState
    struct State {
        var name: String
    }

    enum Action {}

    @Dependency(\.apiClient) var apiClient

    var body: some Reducer<State, Action> {

    }
}
