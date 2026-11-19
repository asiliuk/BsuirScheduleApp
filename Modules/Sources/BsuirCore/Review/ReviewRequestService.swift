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
    #if os(iOS)
    static let liveValue: any ReviewRequestService = LiveReviewRequestService(storage: .standard)
    #else
    static let liveValue: any ReviewRequestService = ReviewRequestServiceMock()
    #endif
    static let previewValue: any ReviewRequestService = ReviewRequestServiceMock()
}

// MARK: - Mock

final class ReviewRequestServiceMock: ReviewRequestService {
    private(set) var events: [MeaningfulEvent] = []
    func madeMeaningfulEvent(_ event: MeaningfulEvent) async {
        events.append(event)
    }
}
