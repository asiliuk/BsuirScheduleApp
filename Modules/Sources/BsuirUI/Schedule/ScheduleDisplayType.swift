import Foundation
import ScheduleCore

extension ScheduleDisplayType {
    public static var pickerTitle: LocalizedStringResource {
        .screenScheduleScheduleTypePickerTitle
    }

    public var title: LocalizedStringResource {
        switch self {
        case .continuous:
            return .screenScheduleScheduleTypeSchedule
        case .compact:
            return .screenScheduleScheduleTypeByDay
        case .exams:
            return .screenScheduleScheduleTypeExams
        }
    }

    public var imageName: String {
        switch self {
        case .continuous:
            return "calendar.day.timeline.leading"
        case .compact:
            return "calendar"
        case .exams:
            return "graduationcap"
        }
    }
}
