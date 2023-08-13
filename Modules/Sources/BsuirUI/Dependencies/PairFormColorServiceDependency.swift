import Foundation
import Dependencies

extension DependencyValues {
    public var pairFormColorService: PairFormColorService {
        get { self[PairFormColorServiceKey.self] }
        set { self[PairFormColorServiceKey.self] = newValue }
    }
}

enum PairFormColorServiceKey: DependencyKey {
    static let liveValue: PairFormColorService = {
        @Dependency(\.widgetService) var widgetService
        return PairFormColorService(
            storage: .asiliukShared,
            widgetService: widgetService
        )
    }()

    static let testValue = PairFormColorService(
        storage: .mock(suiteName: "PairFormColorService"),
        widgetService: .testValue
    )
}
