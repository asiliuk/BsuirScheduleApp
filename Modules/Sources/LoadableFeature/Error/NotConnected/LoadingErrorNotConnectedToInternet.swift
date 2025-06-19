import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorNotConnectedToInternet {
    @ObservableState
    public struct State {}

    public enum Action {
        case reloadButtonTapped
    }
}
