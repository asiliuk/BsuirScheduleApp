import Foundation
import CasePaths
import ScheduleFeature

extension EntityScheduleFeature.State {
    public mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        try? (/Self.group).modify(&self) { $0.schedule.switchDisplayType(displayType) }
        try? (/Self.lector).modify(&self) { $0.schedule.switchDisplayType(displayType) }
    }
}
