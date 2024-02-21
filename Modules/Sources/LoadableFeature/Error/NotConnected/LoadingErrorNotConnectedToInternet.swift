import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorNotConnectedToInternet {
    @ObservableState
    public struct State: Equatable {}

    public enum Action: Equatable {
        case reloadButtonTapped
    }
}
