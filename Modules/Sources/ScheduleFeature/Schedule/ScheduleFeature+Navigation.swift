import Foundation

extension ScheduleFeature.State {
    public mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        scheduleType = displayType
    }

    public mutating func reset() {
        switch scheduleType {
        case .compact:
            schedule?.compact.reset()
        case .exams:
            schedule?.exams.reset()
        case .continuous:
            schedule?.continuous.reset()
        }
    }
}
