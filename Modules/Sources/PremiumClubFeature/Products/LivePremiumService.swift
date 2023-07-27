import Foundation
import BsuirCore
import Combine

final class LivePremiumService: PremiumService {
    @PersistedValue public var isCurrentlyPremium: Bool
    public let isPremium: AnyPublisher<Bool, Never>

    init(storage: UserDefaults = .asiliukShared) {
        // It is used only for initial state check and then is updated by
        // whatever Transaction.currentEntitlements has. So it is OK to store it in user defaults
        // even if somebody overrides it, there's no security risk, it would be overriden back by app
        (_isCurrentlyPremium, isPremium) = storage
            .persistedBool(forKey: "is-premium-service-active")
            .withPublisher()
    }
}
