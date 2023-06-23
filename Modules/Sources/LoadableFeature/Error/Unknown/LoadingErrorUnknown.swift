import Foundation
import ComposableArchitecture

public struct LoadingErrorUnknown: ReducerProtocol {
    public typealias State = Void

    public enum Action: Equatable {
        case reloadButtonTapped
    }

    public var body: some ReducerProtocolOf<Self> {
        EmptyReducer()
    }
}
