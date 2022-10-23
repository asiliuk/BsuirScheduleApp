import Foundation
import Dependencies
import os.log

extension DependencyValues {
    public var reviewRequestService: ReviewRequestServiceProtocol {
        get { self[ReviewRequestServiceKey.self] }
        set { self[ReviewRequestServiceKey.self] = newValue }
    }
}

private enum ReviewRequestServiceKey: DependencyKey {
    struct ReviewRequestServiceNoop: ReviewRequestServiceProtocol {
        let log = OSLog.bsuirSchedule(category: "Review Request")
        
        func madeMeaningfulEvent(_ event: MeaningfulEvent) {
            os_log(log: log, "Meaningful event happen with score: \(event.score)")
        }
    }
    
    static let liveValue: ReviewRequestServiceProtocol = ReviewRequestServiceNoop()
}
