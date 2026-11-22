import SwiftUI

struct NoScheduleView: View {
    var body: some View {
        Text(.widgetScheduleNoSchedule)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct NoExamsView: View {
    var body: some View {
        Text(.widgetScheduleNoExams)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

