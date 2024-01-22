import Foundation
import ScheduleFeature
import ScheduleCore

extension PinnedTabFeature.State {
    mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        pinnedSchedule?.switchDisplayType(displayType)
    }

    mutating func show(pinned: ScheduleSource) {
        pinnedSchedule = .init(pinned: pinned)
    }

    mutating func resetPinned() {
        pinnedSchedule = nil
    }

    mutating func reset() {
        pinnedSchedule?.reset()
    }
}
