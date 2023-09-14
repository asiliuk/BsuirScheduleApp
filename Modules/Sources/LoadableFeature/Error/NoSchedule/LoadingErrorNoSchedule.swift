import Foundation
import ComposableArchitecture

public struct LoadingErrorNoSchedule: Reducer {
    public typealias State = Void

    public enum Action: Equatable {
        case reloadButtonTapped
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
