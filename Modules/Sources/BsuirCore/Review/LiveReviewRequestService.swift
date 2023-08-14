import Foundation
import UIKit
import StoreKit
import Combine
import SwiftUI
import Dependencies

final class LiveReviewRequestService {
    init(storage: UserDefaults) {
        self.storage = storage

        reviewScore.publisher
            .map { ReviewRequestTracking(meaningfulEventsScore: $0, date: Date(), version: Bundle.main.shortVersion) }
            .combineLatest(reviewTrack.publisher)
            .removeDuplicates(by: ==)
            .filter(shouldRequestReview)
            .debounce(for: .seconds(3), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] track, _ in
                self?.requestReview(track: track)
            })
            .store(in: &cancellables)
    }

    private func requestReview(track: ReviewRequestTracking) {
        guard let windowScene = UIApplication.shared.activeWindowScene else {
            assertionFailure()
            return
        }

        SKStoreReviewController.requestReview(in: windowScene)
        reviewTrack.persisted.value = track
    }

    private let storage: UserDefaults
    private var cancellables: Set<AnyCancellable> = []

    private lazy var reviewScore = storage
        .persistedInteger(forKey: "app-review-request.score")
        .withPublisher()

    private lazy var reviewTrack = storage
        .persistedData(forKey: "app-review-request.track")
        .codable(ReviewRequestTracking.self)
        .withPublisher()
}

// MARK: -

extension LiveReviewRequestService: ReviewRequestService {
    func madeMeaningfulEvent(_ event: MeaningfulEvent) async {
        reviewScore.persisted.value += event.score
    }
}

// MARK: - Helpers

private extension UIApplication {
    var activeWindowScene: UIWindowScene? {
        connectedScenes.lazy
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}

private func shouldRequestReview(new: ReviewRequestTracking, old: ReviewRequestTracking?) -> Bool {
    guard new.meaningfulEventsScore - (old?.meaningfulEventsScore ?? 0) > 30 else { return false }
    guard new.version != old?.version else { return false }
    guard let oldDate = old?.date else { return true }
    return new.date.timeIntervalSince(oldDate) > 3600 * 24 * 30
}

private struct ReviewRequestTracking: Equatable, Codable {
    var meaningfulEventsScore: Int
    let date: Date
    let version: ShortAppVersion
}
