import SwiftUI
import BsuirUI
import ScheduleCore

struct ScheduleWidgetEntryAccessoryRectangularView: View {
    var entry: ScheduleEntry
    
    var body: some View {
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
