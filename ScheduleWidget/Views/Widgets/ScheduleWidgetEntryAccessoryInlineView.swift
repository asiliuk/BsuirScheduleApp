import SwiftUI
import WidgetKit
import BsuirUI
import ScheduleCore

struct ScheduleWidgetEntryAccessoryInlineView: View {
    var entry: ScheduleEntry
    
    var body: some View {
        switch entry.content {
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
                let form = Text(PairViewForm(pair.form).shortName)
                InlineView(text: "\(pair.from) \(form) \(pair.subject ?? "")")
            }
        }
    }
}

private struct InlineView: View {
    let text: LocalizedStringKey

    var body: some View {
        Text("\(Image.bsuirLogo) \(Text(text))")
    }
}

struct Previews_ScheduleWidgetEntryAccessoryInlineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScheduleWidgetEntryAccessoryInlineView(entry: .noPinned)
                .previewDisplayName("No Pinned")
            ScheduleWidgetEntryAccessoryInlineView(entry: .placeholder)
                .previewDisplayName("Placeholder")
            ScheduleWidgetEntryAccessoryInlineView(entry: .preview)
                .previewDisplayName("Preview")
        }
        .previewContext(WidgetPreviewContext(family: .accessoryInline))
    }
}
