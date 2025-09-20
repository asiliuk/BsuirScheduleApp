import Foundation

extension ScheduleFeature.State {
    public mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        scheduleDisplayType = displayType
        schedule.loaded?.switchDisplayType(displayType)
    }
}
