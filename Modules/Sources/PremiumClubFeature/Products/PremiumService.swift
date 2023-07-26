import Foundation
import Combine
import Dependencies

public protocol PremiumService {
    var isCurrentlyPremium: Bool { get }
    var isPremium: AnyPublisher<Bool, Never> { get }
}

// MARK: - Dependency

extension DependencyValues {
    public var premiumService: any PremiumService {
        get { self[PremiumServiceKey.self] }
        set { self[PremiumServiceKey.self] = newValue }
    }
}

private enum PremiumServiceKey: DependencyKey {
#if DEBUG
    static let liveValue: any PremiumService = {
        @Dependency(\.debugPremiumService) var debugPremiumService
        return debugPremiumService
    }()
#else
    static let liveValue: any PremiumService = ProductsServiceKey.liveValue
#endif
}
