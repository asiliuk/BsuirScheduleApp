import Foundation
import Combine
import BsuirCore
import Dependencies

#if DEBUG
public final class DebugPremiumService: PremiumService {
    @PersistedValue public var isCurrentlyPremium: Bool
    public let isPremium: AnyPublisher<Bool, Never>

    init(storage: UserDefaults = .asiliukShared) {
        (_isCurrentlyPremium, isPremium) = storage
            .persistedBool(forKey: "debug-is-premium")
            .withPublisher()
    }
}

// MARK: - Dependency

extension DependencyValues {
    public var debugPremiumService: DebugPremiumService {
        get { self[DebugPremiumService.self] }
        set { self[DebugPremiumService.self] = newValue }
    }
}

extension DebugPremiumService: DependencyKey {
    public static let liveValue = DebugPremiumService()
}
#endif
