import SwiftUI

struct NoScheduleView: View {
    var body: some View {
        Text("widget.schedule.noSchedule", bundle: .module)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct NoExamsView: View {
    var body: some View {
        Text("widget.schedule.noExams", bundle: .module)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

