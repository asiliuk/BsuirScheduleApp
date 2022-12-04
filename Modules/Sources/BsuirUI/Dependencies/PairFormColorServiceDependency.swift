import Foundation
import Dependencies

extension DependencyValues {
    public var pairFormColorService: PairFormColorService {
        get { self[PairFormColorServiceKey.self] }
        set { self[PairFormColorServiceKey.self] = newValue }
    }
}

private enum PairFormColorServiceKey: DependencyKey {
    static let liveValue = PairFormColorService(storage: .asiliukShared)
}
