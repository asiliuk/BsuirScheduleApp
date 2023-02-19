import SwiftUI
import BsuirUI
import BsuirCore
import ScheduleCore

struct ScheduleWidgetEntryLargeView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                WidgetDateTitle(date: entry.date)
                Spacer()
                ScheduleIdentifierTitle(title: entry.title)
            }

            switch entry.content {
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
                    maxVisibleCount: 6
                )

                VStack(alignment: .leading, spacing: 4) {
                    RemainingPairsView(pairs: pairs.passedInvisible, visibleCount: 3, showTime: .last)
                        .padding(.leading, 10)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(pairs.visible) { pair in
                            PairView<EmptyView>(pair: pair, isCompact: true, showWeeks: false)
                                .padding(.leading, 10)
                                .padding(.vertical, 2)
                                .background(ContainerRelativeShape().foregroundColor(Color(.secondarySystemBackground)))
                        }
                    }

                    Spacer(minLength: 0)

                    RemainingPairsView(pairs: pairs.upcomingInvisible, visibleCount: 3, showTime: .first)
                        .padding(.leading, 10)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
