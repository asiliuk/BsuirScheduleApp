import SwiftUI
import BsuirCore
import ScheduleCore

public struct ScheduleWidgetEntrySmallView: View {
    var config: ScheduleWidgetConfiguration
    var date: Date

    public init(config: ScheduleWidgetConfiguration, date: Date) {
        self.config = config
        self.date = date
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                ScheduleIdentifierTitle(title: config.title)
                Spacer(minLength: 0)
            }

            WidgetDateTitle(date: date, isSmall: true)

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
                    PairView(pair: pair, distribution: .vertical, isCompact: true, showWeeks: false)
                }
                Spacer(minLength: 0)

                RemainingPairsView(pairs: pairs.upcomingInvisible, visibleCount: 1, showTime: .hide)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}
