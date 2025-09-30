import SwiftUI
import BsuirCore
import ScheduleCore

public struct PinnedScheduleWidgetSmallView: View {
    var config: PinnedScheduleWidgetConfiguration

    @Environment(\.widgetRenderingMode) var renderingMode
    @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

    public init(config: PinnedScheduleWidgetConfiguration) {
        self.config = config
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                ScheduleIdentifierTitle(title: config.title)
                Spacer(minLength: 0)
                ScheduleSubgroupLabel(subgroup: config.subgroup)
                    .foregroundStyle(.secondary)
            }

            if let day = config.day {
                WidgetDateTitle(date: day, isSmall: increasePaddings)
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
                    maxVisibleCount: 1
                )

                Spacer(minLength: 0)

                ForEach(pairs.visible) { pair in
                    PairView(
                        pair: pair,
                        distribution: .vertical,
                        isCompact: increasePaddings,
                        spellForm: spellForm,
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
        .padding(.horizontal, increasePaddings ? -4 : 0)
        .padding(.vertical, increasePaddings ? -6 : 0)
        .widgetBackground(Color(.systemBackground))
    }

    private var spellForm: Bool {
        switch renderingMode {
        case .vibrant, .accented: true
        default: false
        }
    }

    private var increasePaddings: Bool {
        switch renderingMode {
        case .fullColor: showsWidgetBackground
        case .vibrant: false
        default: true
        }
    }
}
