import Foundation
import UIKit
import StoreKit
import Combine
import SwiftUI

public struct MeaningfulEvent {
    public let score: Int
    public init(score: Int) {
        self.score = score
    }
}

public final class ReviewRequestService {

    public func madeMeaningfulEvent(_ event: MeaningfulEvent) {
        reviewScore.persisted.value += event.score
    }

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
        .persistedInteger(key: "app-review-request.score")
        .publisher()

    private lazy var reviewTrack = storage
        .persistedCodable(ReviewRequestTracking.self, key: "app-review-request.track")
        .publisher()
}

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

private struct PersistedValue<Value> {
    var value: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }

    let get: () -> Value
    let set: (Value) -> Void
}

private extension UserDefaults {
    func persistedInteger(key: String) -> PersistedValue<Int> {
        PersistedValue(
            get: { self.integer(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }

    func persistedCodable<Value: Codable>(_ value: Value.Type = Value.self, key: String) -> PersistedValue<Value?> {
        PersistedValue(
            get: { self.data(forKey: key).flatMap { try? JSONDecoder().decode(Value.self, from: $0) } },
            set: { self.set($0.flatMap { try? JSONEncoder().encode($0) }, forKey: key) }
        )
    }
}

extension PersistedValue {
    func publisher() -> (persisted: PersistedValue, publisher:  AnyPublisher<Value, Never>) {
        let subject = CurrentValueSubject<Value, Never>(get())
        return (
            persisted: PersistedValue(get: get, set: { subject.send($0); self.set($0) }),
            publisher: subject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Events

extension MeaningfulEvent {
    static let addToFavorites = Self(score: 5)
    static let scheduleModeSwitched = Self(score: 3)
    static let scheduleRequested = Self(score: 2)
    static let moreScheduleRequested = Self(score: 1)
}
