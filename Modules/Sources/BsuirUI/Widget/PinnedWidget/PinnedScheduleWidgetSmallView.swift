import SwiftUI
import BsuirCore
import ScheduleCore

public struct PinnedScheduleWidgetSmallView: View {
    var config: PinnedScheduleWidgetConfiguration
    var date: Date

    @Environment(\.widgetRenderingMode) var renderingMode
    @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

    public init(config: PinnedScheduleWidgetConfiguration, date: Date) {
        self.config = config
        self.date = date
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                ScheduleIdentifierTitle(title: config.title)
                Spacer(minLength: 0)
                ScheduleSubgroupLabel(subgroup: config.subgroup)
                    .foregroundStyle(.secondary)
            }

            WidgetDateTitle(date: date, isSmall: showsWidgetBackground)

            switch config.content {
            case .noPinned:
                NoPinnedScheduleView()
            case .needsConfiguration:
                NeedsConfigurationView()
            case .pairs(_, []):
                NoPairsView()
            case let .pairs(passed, upcoming):
                let pairs = PairsToDisplay(
                    passed: passed,
                    upcoming: upcoming,
                    maxVisibleCount: 1
                )

                Spacer(minLength: 0)

                ForEach(pairs.visible) { pair in
                    PairView(
                        pair: pair,
                        distribution: .vertical,
                        isCompact: showsWidgetBackground,
                        spellForm: renderingMode == .vibrant,
                        showWeeks: false
                    )
                }

                Spacer(minLength: 0)

                RemainingScheduleView(
                    subjects: pairs.upcomingInvisible.compactMap(\.subject),
                    visibleCount: 1
                )
            }
        }
        .widgetPadding()
        .padding(.horizontal, showsWidgetBackground ? -4 : 0)
        .padding(.vertical, showsWidgetBackground ? -6 : 0)
        .widgetBackground(Color(.systemBackground))
    }
}
