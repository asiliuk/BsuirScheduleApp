import SwiftUI
import BsuirCore
import ScheduleCore

public struct PinnedScheduleWidgetMediumView : View {
    var config: PinnedScheduleWidgetConfiguration
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    public init(config: PinnedScheduleWidgetConfiguration) {
        self.config = config
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                config.day.map { WidgetDateTitle(date: $0) }
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
            case .noSchedule:
                NoScheduleView()
            case .failed(let refresh):
                ScheduleRequestFailedView(refresh: refresh)
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
                        PairView<EmptyView>(
                            pair: pair,
                            isCompact: true,
                            spellForm: widgetRenderingMode == .accented,
                            showWeeks: false
                        )
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
