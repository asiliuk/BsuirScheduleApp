import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorUnknown {
    @ObservableState
    public struct State {}

    public enum Action {
        case reloadButtonTapped
    }
}
