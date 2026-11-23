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
            InlineView(text: Text(.widgetNoPinnedTitle))

        case .noSchedule:
            InlineView(text: Text(.widgetScheduleNoSchedule))

        case .failed:
            InlineView(text: Text(.widgetFailedTitle))

        case .pairs(_, []):
            InlineView(text: Text(.widgetScheduleEmpty))

        case let .pairs(passed, upcoming):
            let pairs = PairsToDisplay(
                passed: passed,
                upcoming: upcoming,
                maxVisibleCount: 1
            )

            if let pair = pairs.visible.last {
                let form = Image(systemName: pair.form.symbolName)
                InlineView(text: Text(verbatim: "\(pair.from) \(form) \(pair.subject ?? "")"))
            }
        }
    }
}

private struct InlineView: View {
    let text: Text

    var body: some View {
        Text(verbatim: "\(Image.bsuirLogo) \(text)")
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
