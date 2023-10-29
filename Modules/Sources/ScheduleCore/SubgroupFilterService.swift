import Foundation
import Dependencies
import BsuirCore

extension DependencyValues {
    public var subgroupFilterService: SubgroupFilterService {
        get { self[SubgroupFilterServiceKey.self] }
        set { self[SubgroupFilterServiceKey.self] = newValue }
    }
}

public struct SubgroupFilterService {
    public var preferredSubgroup: @Sendable (_ source: ScheduleSource) -> PersistedValue<Int?>
}

private enum SubgroupFilterServiceKey: DependencyKey {
    static let liveValue = SubgroupFilterService { source in
        let key = switch source {
        case .group(let name): "group_\(name)_preferredSubgroup"
        case .lector(let employee): "lector_\(employee.id)_preferredSubgroup"
        }
        return UserDefaults.asiliukShared
            .persistedInteger(forKey: key)
            // Transform 0 subgroup to nil
            .map(fromValue: { $0 == 0 ? nil : $0 }, toValue: { $0 ?? 0 })
    }

    static let previewValue = SubgroupFilterService(preferredSubgroup: { _ in .constant(1) })
}
