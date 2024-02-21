import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorNoSchedule {
    @ObservableState
    public struct State: Equatable {}

    public enum Action: Equatable {
        case reloadButtonTapped
    }
}
