import Foundation
import ComposableArchitecture

extension PersistenceKey where Self == PersistenceKeyDefault<AppStorageKey<Bool>> {
    // It is used only for initial state check and then is updated by
    // whatever Transaction.currentEntitlements has. So it is OK to store it in user defaults
    // even if somebody overrides it, there's no security risk, it would be override back by app
    public static var isPremiumUser: Self {
        PersistenceKeyDefault(
            .appStorage(isUserPremiumKey),
            false
        )
    }
}

extension UserDefaults {
    /// Used in Widgets because they do not support TCA yet
    ///
    /// By default plain and not shared user defaults are used in `AppStorageKey`it is tricky to override it in non-TCA context.
    /// So until then this property is used
    public var isUserPremium: Bool {
        bool(forKey: isUserPremiumKey)
    }
}

private let isUserPremiumKey = "is-premium-service-active"
