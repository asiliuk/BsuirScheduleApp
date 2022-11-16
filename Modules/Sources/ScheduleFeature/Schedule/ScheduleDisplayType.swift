import Foundation
import SwiftUI

enum ScheduleDisplayType: Hashable, CaseIterable {
    case continuous
    case compact
    case exams
}

extension ScheduleDisplayType {
    var title: LocalizedStringKey {
        switch self {
        case .continuous:
            return "screen.schedule.scheduleType.schedule"
        case .compact:
            return "screen.schedule.scheduleType.byDay"
        case .exams:
            return "screen.schedule.scheduleType.exams"
        }
    }

    var imageName: String {
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
