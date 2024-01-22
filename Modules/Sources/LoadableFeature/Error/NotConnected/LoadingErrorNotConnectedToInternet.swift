import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorNotConnectedToInternet {
    public typealias State = Void

    public enum Action: Equatable {
        case reloadButtonTapped
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
