import Foundation
import ComposableArchitecture

public struct LoadingErrorNotConnectedToInternet: ReducerProtocol {
    public typealias State = Void

    public enum Action: Equatable {
        case reloadButtonTapped
    }

    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}
