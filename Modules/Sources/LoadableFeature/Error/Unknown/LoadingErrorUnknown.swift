import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorUnknown {
    @ObservableState
    public struct State: Equatable {}

    public enum Action: Equatable {
        case reloadButtonTapped
    }
}
