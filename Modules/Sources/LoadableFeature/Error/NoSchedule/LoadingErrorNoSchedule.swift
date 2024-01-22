import Foundation
import ComposableArchitecture

@Reducer
public struct LoadingErrorNoSchedule {
    public typealias State = Void

    public enum Action: Equatable {
        case reloadButtonTapped
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
