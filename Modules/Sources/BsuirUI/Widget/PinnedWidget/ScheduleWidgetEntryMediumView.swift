import SwiftUI
import BsuirCore
import ScheduleCore

public struct ScheduleWidgetEntryMediumView : View {
    var config: ScheduleWidgetConfiguration
    var date: Date

    public init(config: ScheduleWidgetConfiguration, date: Date) {
        self.config = config
        self.date = date
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                WidgetDateTitle(date: date)
                Spacer()
                ScheduleIdentifierTitle(title: config.title)
            }

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
                    maxVisibleCount: 2
                )

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(pairs.visible) { pair in
                        PairView<EmptyView>(pair: pair, isCompact: true, showWeeks: false)
                    }
                }
                .padding(.top, 6)

                Spacer(minLength: 0)

                RemainingPairsView(pairs: pairs.upcomingInvisible, visibleCount: 3, showTime: .first)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
