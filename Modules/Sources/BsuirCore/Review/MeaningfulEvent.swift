import Foundation

public struct MeaningfulEvent {
    public let score: Int
    public init(score: Int) {
        self.score = score
    }
}

extension MeaningfulEvent {
    static let addToFavorites = Self(score: 5)
    static let scheduleModeSwitched = Self(score: 3)
    static let scheduleRequested = Self(score: 2)
    static let moreScheduleRequested = Self(score: 1)
}
