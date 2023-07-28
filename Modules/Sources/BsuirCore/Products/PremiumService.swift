import Foundation
import Combine
import Dependencies

public protocol PremiumService: AnyObject {
    var premiumExpirationDate: Date? { get set }
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

public enum PremiumServiceKey: DependencyKey {
    public static let liveValue: any PremiumService = {
        @Dependency(\.widgetService) var widgetService
        return LivePremiumService(widgetService: widgetService)
    }()

    public static let testValue: any PremiumService = PremiumServiceMock()
}

// MARK: - Mock

#if DEBUG
public final class PremiumServiceMock: PremiumService {
    public var premiumExpirationDate: Date?

    public let _isPremium: CurrentValueSubject<Bool, Never>

    public var isCurrentlyPremium: Bool {
        get { _isPremium.value }
        set { _isPremium.value = newValue }
    }

    public var isPremium: AnyPublisher<Bool, Never> {
        _isPremium.eraseToAnyPublisher()
    }

    public init(isPremium: Bool = false) {
        self._isPremium = CurrentValueSubject(isPremium)
    }
}
#endif
