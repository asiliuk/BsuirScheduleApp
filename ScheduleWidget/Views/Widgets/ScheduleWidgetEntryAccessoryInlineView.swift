import SwiftUI
import BsuirUI
import ScheduleCore

/// Not yet supported
///
/// Needs predefined configuration to work. No way to configure as other widgets
struct ScheduleWidgetEntryAccessoryInlineView: View {
    var entry: Provider.Entry
    
    var body: some View {
        switch entry.content {
        case .needsConfiguration:
            HStack {
                BsuirImage()
                Text("widget.needsConfiguration.selectSchedule")
            }
        case .pairs(_, []):
            HStack {
                BsuirImage()
                Text("widget.schedule.empty")
            }
        case let .pairs(passed, upcoming):
            let pairs = PairsToDisplay(
                passed: passed,
                upcoming: upcoming,
                maxVisibleCount: 1
            )
            
            ForEach(pairs.visible) { pair in
                HStack {
                    BsuirImage()
                    Text("\(pair.from)")
                    Text(PairViewForm(pair.form).shortName)
                    pair.subject.map(Text.init(verbatim:))
                }
            }
        }
    }
}
