import SwiftUI
import ComposableArchitecture
import ScheduleCore
import BsuirUI

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
        PairView(
            pair: pair,
            distribution: .vertical,
            isCompact: true,
            isCompactProgress: true,
            spellForm: false,
            showWeeks: true
        )
        .listItemTint(pair.form.viewForm.defaultColor.color)
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
