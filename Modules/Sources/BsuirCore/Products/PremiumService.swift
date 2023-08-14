import Foundation
import Combine
import Dependencies

public protocol PremiumService: AnyObject {
    var isCurrentlyPremium: Bool { get set }
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
    static let liveValue: any PremiumService = {
        @Dependency(\.widgetService) var widgetService
        return LivePremiumService(widgetService: widgetService)
    }()

    static let previewValue: any PremiumService = PremiumServiceMock(isPremium: true)
    static let testValue: any PremiumService = PremiumServiceMock()
}

// MARK: - Mock

#if DEBUG
public final class PremiumServiceMock: PremiumService {
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
