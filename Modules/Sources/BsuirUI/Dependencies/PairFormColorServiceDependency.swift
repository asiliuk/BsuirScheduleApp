import Foundation
import Dependencies

extension DependencyValues {
    public var pairFormDisplayService: PairFormDisplayService {
        get { self[PairFormDisplayServiceKey.self] }
        set { self[PairFormDisplayServiceKey.self] = newValue }
    }
}

private enum PairFormDisplayServiceKey: DependencyKey {
    static let liveValue: PairFormDisplayService = {
        @Dependency(\.widgetService) var widgetService
        return PairFormDisplayService(
            storage: .asiliukShared,
            widgetService: widgetService
        )
    }()

    static let testValue = PairFormDisplayService(
        storage: .mock(suiteName: "PairFormColorService"),
        widgetService: .noop
    )
}
