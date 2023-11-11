import Foundation
import Combine

final class LivePremiumService: PremiumService {
    private let widgetService: WidgetService

    @PersistedValue public var isCurrentlyPremium: Bool {
        didSet {
            guard oldValue != isCurrentlyPremium else { return }
            widgetService.reloadAll()
        }
    }

    public let isPremium: AnyPublisher<Bool, Never>

    init(
        storage: UserDefaults = .asiliukShared,
        widgetService: WidgetService
    ) {
        self.widgetService = widgetService
        // It is used only for initial state check and then is updated by
        // whatever Transaction.currentEntitlements has. So it is OK to store it in user defaults
        // even if somebody overrides it, there's no security risk, it would be overriden back by app
        (_isCurrentlyPremium, isPremium) = storage
            .persistedBool(forKey: "is-premium-service-active")
            .withPublisher()
    }
}
