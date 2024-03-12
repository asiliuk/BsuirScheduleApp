import Foundation

extension ScheduleFeature.State {
    public mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        scheduleType = displayType
    }
}
