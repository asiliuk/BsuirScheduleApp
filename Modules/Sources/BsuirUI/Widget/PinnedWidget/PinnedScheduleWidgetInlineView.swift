import SwiftUI
import ScheduleCore

public struct PinnedScheduleWidgetInlineView: View {
    var config: PinnedScheduleWidgetConfiguration

    public init(config: PinnedScheduleWidgetConfiguration) {
        self.config = config
    }
    
    public var body: some View {
        switch config.content {
        case .noPinned:
            InlineView(text: "widget.noPinned.title")

        case .noSchedule:
            InlineView(text: "widget.schedule.noSchedule")

        case .failed:
            InlineView(text: "widget.failed.title")

        case .pairs(_, []):
            InlineView(text: "widget.schedule.empty")

        case let .pairs(passed, upcoming):
            let pairs = PairsToDisplay(
                passed: passed,
                upcoming: upcoming,
                maxVisibleCount: 1
            )

            if let pair = pairs.visible.last {
                let form = Image(systemName: pair.form.symbolName)
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
            PinnedScheduleWidgetInlineView(config: .noPinned())
                .previewDisplayName("No Pinned")
            PinnedScheduleWidgetInlineView(config: .placeholder)
                .previewDisplayName("Placeholder")
            PinnedScheduleWidgetInlineView(config: .preview)
                .previewDisplayName("Preview")
        }
    }
}
