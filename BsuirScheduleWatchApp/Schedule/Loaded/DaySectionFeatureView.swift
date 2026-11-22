import SwiftUI
import ComposableArchitecture
import ScheduleCore

struct DaySectionFeatureView: View {
    let store: StoreOf<DaySectionFeature>

    var body: some View {
        Section {
            ForEach(store.pairs) { pair in
                PairRow(pair: pair)
            }
        } header: {
            Text(store.title)
        }
    }
}

private struct PairRow: View {
    let pair: PairViewModel

    var body: some View {
        HStack(alignment: .center) {
            PairFormIndicator(
                color: pair.form.defaultColor,
                progress: 0,
                formIndicatorWidth: 4
            )
            VStack(alignment: .leading) {
                Text(pair.interval)
                    .font(.subheadline)
                if let subject = pair.subject {
                    Text(subject)
                        .font(.headline)
                }
                if let note = pair.note {
                    Text(note).font(.caption2)
                }
            }
        }
        .listItemTint(pair.form.defaultColor)
    }
}

struct PairFormIndicator: View {
    var color: Color
    var progress: Double
    @ScaledMetric(relativeTo: .body) var formIndicatorWidth: CGFloat = 8
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.redactionReasons) var redactionReasons

    var body: some View {
        GeometryReader { proxy in
            PillPairFormIndicator(
                progress: progress,
                proxy: proxy,
                passedOpacity: passedOpacity
            )
        }
        .foregroundColor(redactionReasons.contains(.placeholder) ? .gray : color)
        .frame(width: formIndicatorWidth)
    }

    private var passedOpacity: Double {
        colorScheme == .dark ? 0.5 : 0.3
    }
}

private struct PillPairFormIndicator: View {
    var progress: Double
    var proxy: GeometryProxy
    var passedOpacity: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .opacity(passedOpacity)

            Capsule()
                .frame(height: progressHeight)
        }
    }

    private var progressHeight: CGFloat {
        let height = proxy.size.height
        guard progress > 0 else { return height }
        guard progress < 1 else { return 0 }
        return max(height * CGFloat(1 - progress), proxy.size.width)
    }
}

private extension PairViewModel.Form {
    var defaultColor: Color {
        switch self {
        case .lecture: .green
        case .practice: .red
        case .lab: .yellow
        case .consultation: .brown
        case .exam: .purple
        case .test: .indigo
        case .unknown: .gray
        }
    }
}

import BsuirApi

#Preview("Row") {
    PairRow(pair: PairViewModel(
        from: "8:00",
        to: "10:30",
        interval: "8:30-10:30",
        form: .practice,
        subject: "ОАиП",
        subjectFullName: nil,
        auditory: "403k1"
    ))
}

#Preview("Section") {
    let store = Store(
        initialState: DaySectionFeature.State(
            id: UUID(),
            title: "Понедельник",
            pairs: [
                PairViewModel(
                    start: try? Date("2026-01-01T08:00:00+03:00", strategy: .iso8601),
                    end: try? Date("2026-01-01T10:30:00+03:00", strategy: .iso8601),
                    pair: Pair(
                        subject: "Физика",
                        auditories: ["145", "252"],
                        subgroup: 2,
                        lessonType: .practice,
                        weekNumber: .evenWeeks,
                        note: nil,
                        employees: [],
                        studentGroups: [],
                    ),
                    progress: .init(constant: 0)
                ),
                PairViewModel(
                    start: try? Date("2026-01-01T10:45:00+03:00", strategy: .iso8601),
                    end: try? Date("2026-01-01T12:00:00+03:00", strategy: .iso8601),
                    pair: Pair(
                        subject: "МиАПР",
                        auditories: ["503k4"],
                        subgroup: 2,
                        lessonType: .lecture,
                        weekNumber: .evenWeeks,
                        note: "что у вас происходит",
                        employees: [],
                        studentGroups: [],
                    ),
                    progress: .init(constant: 0)
                ),
            ]
        )
    ) { DaySectionFeature() }
    List {
        DaySectionFeatureView(store: store)
    }
}
