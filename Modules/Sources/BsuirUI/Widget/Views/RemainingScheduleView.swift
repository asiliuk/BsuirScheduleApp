import SwiftUI
import BsuirCore
import ScheduleCore

struct RemainingScheduleView: View {
    var prefix: String?
    var subjects: [String]
    let visibleCount: Int

    var body: some View {
        if !subjects.isEmpty {
            HStack {
                prefix.map(Text.init)
                    .font(.system(.footnote, design: .monospaced))

                Circle().frame(width: 8, height: 8)

                Text(morePairs)
                    .font(.footnote)
            }
            .foregroundColor(.secondary)
        }
    }

    private var morePairs: String {
        subjects
            .formatted(
                visibleCount: visibleCount,
                placeholder: { String(localized: "widget.schedule.more.\($0)", bundle: .module) }
            )
    }
}
