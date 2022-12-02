import Foundation
import ComposableArchitecture

public struct LoadingErrorSomethingWrongWithBsuir: ReducerProtocol {
    public struct State: Equatable {
        init(url: URL?, description: String, statusCode: Int?) {
            fatalError()
        }
    }
    public enum Action: Equatable {
        case reloadButtonTapped
    }

    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}
