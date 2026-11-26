import SwiftUI
import BsuirUI
import ScheduleCore

struct PairRowView: View {
    let pair: PairViewModel
    let showWeeks: Bool
    @Environment(\.pairFilteringMode) var pairFilteringMode

    var body: some View {
        if pair.matches(filteringMode: pairFilteringMode) {
            PairView(
                pair: pair,
                distribution: .oneLineVertical,
                isCompact: true,
                isCompactProgress: true,
                showWeeks: showWeeks
            )
            .listRowBackground(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.secondary.opacity(0.5), style: .filteredPair)
            )
            .foregroundStyle(.secondary)
        } else {
            PairView(
                pair: pair,
                distribution: .vertical,
                isCompact: true,
                isCompactProgress: true,
                spellForm: false,
                showWeeks: showWeeks
            )
        }
    }
}

private extension StrokeStyle {
    static let filteredPair = StrokeStyle(
        lineWidth: 1,
        lineCap: .butt,
        lineJoin: .miter,
        miterLimit: 0,
        dash: [6, 6],
        dashPhase: 0
    )
}

#Preview("Row") {
    List {
        PairRowView(
            pair: PairViewModel(
                from: "8:00",
                to: "10:30",
                interval: "8:30-10:30",
                form: .practice,
                subject: "ОАиП",
                subjectFullName: nil,
                auditory: "403k1"
            ),
            showWeeks: true
        )
        PairRowView(
            pair: PairViewModel(
                from: "8:00",
                to: "10:30",
                interval: "8:30-10:30",
                form: .practice,
                subject: "ОАиП",
                subjectFullName: nil,
                auditory: "403k1"
            ),
            showWeeks: true
        )
        .environment(\.pairFilteringMode, .filter)
    }
}
