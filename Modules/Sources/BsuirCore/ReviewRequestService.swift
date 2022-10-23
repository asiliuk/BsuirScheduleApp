import Foundation

public protocol ReviewRequestServiceProtocol {
    func madeMeaningfulEvent(_ event: MeaningfulEvent)
}

public struct MeaningfulEvent {
    public let score: Int
    public init(score: Int) {
        self.score = score
    }
}
