import SwiftUI
import BsuirCore

struct ScheduleRequestFailedView: View {
    let refresh: Date
    let timeline: WidgetTimeline

    var body: some View {
        VStack(alignment: .leading) {
            Text("widget.failed.title", bundle: .module)
                .font(.headline)
            Text("widget.failed.message\(refresh, style: .relative)", bundle: .module)
                .font(.callout)
                .foregroundStyle(.secondary)

            Button(intent: ReloadTimelineIntent(timeline: timeline)) {
                ScheduleRequestFailedRetryLabel()
            }
            .tint(.gray)
            .controlSize(.mini)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct ScheduleRequestFailedSymbolView: View {
    var body: some View {
        Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
    }
}

private struct ScheduleRequestFailedRetryLabel: View {
    var body: some View {
        Label {
            Text("widget.failed.retry", bundle: .module)
        } icon: {
            Image(systemName: "arrow.clockwise")
        }
    }
}

#Preview {
    ScheduleRequestFailedView(
        refresh: .now.addingTimeInterval(3600 * 25),
        timeline: .examsSchedule
    )
}
