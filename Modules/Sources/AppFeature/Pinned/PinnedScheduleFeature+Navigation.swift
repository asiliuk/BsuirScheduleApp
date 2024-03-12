import Foundation
import ComposableArchitecture
import ScheduleFeature

extension PinnedScheduleFeature.State {
    mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        entitySchedule.switchDisplayType(displayType)
    }

    mutating func reset() {
        path.removeAll()
    }
}
