import SwiftUI
import ScheduleCore

public struct PinnedScheduleWidgetRectangularView: View {
    var config: PinnedScheduleWidgetConfiguration

    public init(config: PinnedScheduleWidgetConfiguration) {
        self.config = config
    }

    public var body: some View {
        Group {
            switch config.content {
            case .noPinned:
                NoPinnedScheduleView()
            case .noSchedule:
                NoScheduleView()
            case .pairs(_, []):
                NoPairsView()
            case let .pairs(passed, upcoming):
                let pairs = PairsToDisplay(
                    passed: passed,
                    upcoming: upcoming,
                    maxVisibleCount: 1
                )
                
                ForEach(pairs.visible) { pair in
                    PairView(
                        pair: pair,
                        distribution: .vertical,
                        isCompact: true,
                        spellForm: true,
                        showWeeks: false
                    )
                }
            }
        }
        .widgetBackground(.clear)
    }
}
