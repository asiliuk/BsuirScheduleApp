import Foundation
import BsuirCore
import Combine

final class LivePremiumService: PremiumService {
    private let storage: UserDefaults

    // It is used only for initial state check and then is updated by
    // whatever Transaction.currentEntitlements has. So it is OK to store it in user defaults
    // even if somebody overrides it, there's no security risk, it would be overriden back by app
    private lazy var subscriptionExpirationStorage = storage
        .persistedDate(forKey: "premium-expiration-date")
        .withPublisher()

    var premiumExpirationDate: Date? {
        get { subscriptionExpirationStorage.persisted.value }
        set { subscriptionExpirationStorage.persisted.value = newValue }
    }

    var isCurrentlyPremium: Bool {
        subscriptionExpirationStorage.persisted.value != nil
    }

    var isPremium: AnyPublisher<Bool, Never> {
        subscriptionExpirationStorage.publisher
            .map { $0 != nil }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init(storage: UserDefaults = .asiliukShared) {
        self.storage = storage
    }
}
