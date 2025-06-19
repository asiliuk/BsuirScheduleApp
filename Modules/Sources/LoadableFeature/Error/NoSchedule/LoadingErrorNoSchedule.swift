import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorNoSchedule {
    @ObservableState
    public struct State {}

    public enum Action {
        case reloadButtonTapped
    }
}
