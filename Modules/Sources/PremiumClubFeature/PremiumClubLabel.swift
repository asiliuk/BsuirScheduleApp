import Foundation
import ComposableArchitecture
import BsuirCore

@Reducer
public struct PremiumClubLabel {
    @ObservableState
    public struct State {
        @SharedReader(.isPremiumUser) var isPremiumUser
        public init() {}
    }

    public init() {}
}
