import SwiftUI
import BsuirCore
import ScheduleCore

public struct ScheduleWidgetEntrySmallView: View {
    var config: ScheduleWidgetConfiguration
    var date: Date

    @Environment(\.widgetRenderingMode) var renderingMode
    @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

    public init(config: ScheduleWidgetConfiguration, date: Date) {
        self.config = config
        self.date = date
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                ScheduleIdentifierTitle(title: config.title)
                Spacer(minLength: 0)
                ScheduleSubgroupLabel(subgroup: config.subgroup)
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

                RemainingPairsView(pairs: pairs.upcomingInvisible, visibleCount: 1, showTime: .hide)
            }
        }
        .widgetPadding()
        .padding(.horizontal, showsWidgetBackground ? -4 : 0)
        .padding(.vertical, showsWidgetBackground ? -6 : 0)
        .widgetBackground(Color(.systemBackground))
    }
}
