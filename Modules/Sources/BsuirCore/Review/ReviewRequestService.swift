import Foundation
import Dependencies

public protocol ReviewRequestService {
    func madeMeaningfulEvent(_ event: MeaningfulEvent) async
}

// MARK: - Dependency

extension DependencyValues {
    public var reviewRequestService: any ReviewRequestService {
        get { self[ReviewRequestServiceKey.self] }
        set { self[ReviewRequestServiceKey.self] = newValue }
    }
}

private enum ReviewRequestServiceKey: DependencyKey {
    static let liveValue: any ReviewRequestService = LiveReviewRequestService(storage: .standard)
    static let previewValue: any ReviewRequestService = ReviewRequestServiceMock()
}

#if DEBUG
final class ReviewRequestServiceMock: ReviewRequestService {
    private(set) var events: [MeaningfulEvent] = []
    func madeMeaningfulEvent(_ event: MeaningfulEvent) async {
        events.append(event)
    }
}
#endif
