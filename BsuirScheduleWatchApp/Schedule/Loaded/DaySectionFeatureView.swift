import SwiftUI
import ComposableArchitecture
import ScheduleCore
import BsuirUI
import BsuirCore

struct DaySectionFeatureView: View {
    let store: StoreOf<DaySectionFeature>
    let showPairWeeks: Bool

    var body: some View {
        Section {
            ForEach(store.pairs) { pair in
                PairRow(
                    pair: pair,
                    showWeeks: showPairWeeks
                )
            }
        } header: {
            ScheduleDateTitle(
                title: store.title,
                subtitle: store.subtitle,
                relativeDate: store.relativity.title,
                relativity: ScheduleDateTitle.Relativity(
                    order: store.relativity.order
                )
            )
        }
    }
}

private struct PairRow: View {
    let pair: PairViewModel
    let showWeeks: Bool

    var body: some View {
        PairView(
            pair: pair,
            distribution: .vertical,
            isCompact: true,
            isCompactProgress: true,
            spellForm: false,
            showWeeks: showWeeks
        )
        .listItemTint(pair.form.viewForm.defaultColor.color)
    }
}

// MARK: - Title

private extension DaySectionFeature.State {
    var title: String {
        switch day {
        case let .continuous(date, _):
            return date.formatted(.scheduleDay)
        case .weekDay(let weekDay):
            @Dependency(\.calendar) var calendar
            return weekDay.localizedName(in: calendar)
        case let .exact(date):
            return date?.formatted(.examDay) ?? "-/-"
        }
    }

    var subtitle: String? {
        switch day {
        case let .continuous(_, weekNumber):
            String(localized: "screen.schedule.day.subtitle.\(weekNumber)")
        case .weekDay, .exact:
            nil
        }
    }
}

private extension ScheduleDateTitle.Relativity {
    init(order: ComparisonResult) {
        switch order {
        case .orderedSame: self = .today
        case .orderedAscending: self = .passed
        case .orderedDescending: self = .upcoming
        }
    }
}

// MARK: - Preview

import BsuirApi

#Preview("Row") {
    PairRow(
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
}

#Preview("Section") {
    let store = Store(
        initialState: DaySectionFeature.State(
            day: .weekDay(.monday),
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
            ],
            sharedNow: Shared(value: .now)
        )
    ) { DaySectionFeature() }
    List {
        DaySectionFeatureView(store: store, showPairWeeks: true)
    }
}
