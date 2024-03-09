import Foundation

extension ScheduleFeature.State {
    public mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        scheduleType = displayType
    }

    public mutating func reset() {
        guard schedule.is(\.loaded) else { return }
        schedule.modify(\.loaded) { [scheduleType] in
            switch scheduleType {
            case .compact: $0.compact.reset()
            case .exams: $0.exams.reset()
            case .continuous: $0.continuous.reset()
            }
        }
    }
}
