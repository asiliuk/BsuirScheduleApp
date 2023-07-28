import SwiftUI
import ScheduleCore

public struct ScheduleWidgetEntryAccessoryInlineView: View {
    var config: ScheduleWidgetConfiguration

    public init(config: ScheduleWidgetConfiguration) {
        self.config = config
    }
    
    public var body: some View {
        switch config.content {
        case .noPinned:
            InlineView(text: "widget.noPinned.title")

        case .needsConfiguration:
            InlineView(text: "widget.needsConfiguration.selectSchedule")

        case .pairs(_, []):
            InlineView(text: "widget.schedule.empty")

        case let .pairs(passed, upcoming):
            let pairs = PairsToDisplay(
                passed: passed,
                upcoming: upcoming,
                maxVisibleCount: 1
            )

            if let pair = pairs.visible.last {
                let form = Text(PairViewForm(pair.form).shortName, bundle: .module)
                InlineView(text: "\(pair.from) \(form) \(pair.subject ?? "")")
            }
        }
    }
}

private struct InlineView: View {
    let text: LocalizedStringKey

    var body: some View {
        Text("\(Image.bsuirLogo) \(Text(text, bundle: .module))")
    }
}

struct Previews_ScheduleWidgetEntryAccessoryInlineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScheduleWidgetEntryAccessoryInlineView(config: .noPinned())
                .previewDisplayName("No Pinned")
            ScheduleWidgetEntryAccessoryInlineView(config: .placeholder)
                .previewDisplayName("Placeholder")
            ScheduleWidgetEntryAccessoryInlineView(config: .preview)
                .previewDisplayName("Preview")
        }
    }
}
