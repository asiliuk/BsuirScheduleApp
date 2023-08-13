import Foundation

extension UserDefaults {
    public static let asiliukShared = UserDefaults(suiteName: "group.asiliuk.shared.schedule")!
}

#if DEBUG
extension UserDefaults {
    public static func mock(suiteName: String) -> UserDefaults {
        let userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults!.removePersistentDomain(forName: suiteName)
        return userDefaults!
    }
}
#endif
