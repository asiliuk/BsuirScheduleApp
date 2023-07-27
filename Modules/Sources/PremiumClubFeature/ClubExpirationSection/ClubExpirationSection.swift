import Foundation
import ComposableArchitecture

public struct ClubExpirationSection: Reducer {
    public struct State: Equatable {
        var expirationText: TextState {
            let formattedExpiration = expiration?.formatted(date: .long, time: .omitted)
            return TextState("Your subscription will expire \(formattedExpiration ?? "-/-")")
        }
        var expiration: Date?
    }

    public typealias Action = Never

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
