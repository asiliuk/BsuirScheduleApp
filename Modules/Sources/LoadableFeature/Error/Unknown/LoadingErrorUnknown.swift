import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorUnknown {
    public typealias State = Void

    public enum Action: Equatable {
        case reloadButtonTapped
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
