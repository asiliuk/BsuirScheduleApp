import Foundation
import BsuirCore
import Combine

final class LivePremiumService: PremiumService {
    private let storage: UserDefaults
    private let widgetService: WidgetService

    // It is used only for initial state check and then is updated by
    // whatever Transaction.currentEntitlements has. So it is OK to store it in user defaults
    // even if somebody overrides it, there's no security risk, it would be overriden back by app
    private lazy var subscriptionExpirationStorage = storage
        .persistedDate(forKey: "premium-expiration-date")
        .withPublisher()

    var premiumExpirationDate: Date? {
        get { subscriptionExpirationStorage.persisted.value }
        set {
            guard subscriptionExpirationStorage.persisted.value != newValue else {
                return
            }

            subscriptionExpirationStorage.persisted.value = newValue
            widgetService.reload(.pinnedSchedule)
        }
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

    init(
        storage: UserDefaults = .asiliukShared,
        widgetService: WidgetService
    ) {
        self.storage = storage
        self.widgetService = widgetService
    }
}
