import SwiftUI
import BsuirCore
import ScheduleCore

public struct PinnedScheduleWidgetMediumView : View {
    var config: PinnedScheduleWidgetConfiguration
    var date: Date

    public init(config: PinnedScheduleWidgetConfiguration, date: Date) {
        self.config = config
        self.date = date
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                WidgetDateTitle(date: date)
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    ScheduleIdentifierTitle(title: config.title)
                    ScheduleSubgroupLabel(subgroup: config.subgroup)
                        .foregroundStyle(.secondary)
                }
            }

            switch config.content {
            case .noPinned:
                NoPinnedScheduleView()
            case .pairs(_, []):
                NoPairsView()
            case let .pairs(passed, upcoming):
                let pairs = PairsToDisplay(
                    passed: passed,
                    upcoming: upcoming,
                    maxVisibleCount: 2
                )

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(pairs.visible) { pair in
                        PairView<EmptyView>(pair: pair, isCompact: true, showWeeks: false)
                    }
                }
                .padding(.top, 6)

                Spacer(minLength: 0)

                RemainingScheduleView(
                    prefix: pairs.upcomingInvisible.first?.from,
                    subjects: pairs.upcomingInvisible.compactMap(\.subject),
                    visibleCount: 3
                )
            }
        }
        .widgetPadding()
        .widgetBackground(Color(.systemBackground))
    }
}
