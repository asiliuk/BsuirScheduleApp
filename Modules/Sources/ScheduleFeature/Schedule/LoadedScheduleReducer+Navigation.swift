import Foundation

extension LoadedScheduleReducer.State {
    public mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        scheduleType = displayType
    }
}
