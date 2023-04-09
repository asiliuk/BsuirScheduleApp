import SwiftUI
import ScheduleCore

public struct ScheduleWidgetEntryAccessoryRectangularView: View {
    var config: ScheduleWidgetConfiguration

    public init(config: ScheduleWidgetConfiguration) {
        self.config = config
    }

    public var body: some View {
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
}
