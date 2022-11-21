import Foundation
import Dependencies
import os.log

extension DependencyValues {
    public var reviewRequestService: ReviewRequestService {
        get { self[ReviewRequestServiceKey.self] }
        set { self[ReviewRequestServiceKey.self] = newValue }
    }
}

private enum ReviewRequestServiceKey: DependencyKey {
    static let liveValue = ReviewRequestService(storage: .standard)
}
