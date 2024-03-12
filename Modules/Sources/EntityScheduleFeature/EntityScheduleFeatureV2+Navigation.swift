import Foundation
import CasePaths
import ScheduleFeature

extension EntityScheduleFeatureV2.State {
    public mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        switch self {
        case .group:
            modify(\.group) { $0.schedule.switchDisplayType(displayType) }
        case .lector:
            modify(\.lector) { $0.schedule.switchDisplayType(displayType) }
        }
    }
}
