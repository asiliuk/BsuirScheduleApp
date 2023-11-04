import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import BsuirCore
import ScheduleCore
import Combine
import StoreKit
import Dependencies

struct PinnedScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetService.Timeline.pinnedSchedule.rawValue,
            provider: PinnedScheduleProvider()
        ) { entry in
            PinnedScheduleWidgetEntryView(entry: entry)
                .environmentObject({
                    @Dependency(\.pairFormDisplayService) var pairFormDisplayService
                    return pairFormDisplayService
                }())
        }
        .configurationDisplayName("widget.pinned.displayName")
        .supportedFamilies(supportedFamilies)
        .description("widget.pinned.description")
    }

    private let supportedFamilies: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge,
        .accessoryCircular,
        .accessoryRectangular,
        .accessoryInline,
    ]
}

struct PinnedScheduleWidgetEntryView: View {
    let entry: PinnedScheduleEntry
    @Environment(\.widgetFamily) var size

    var body: some View {
        Group {
            switch size {
            case .systemSmall:
                PinnedScheduleWidgetSmallView(config: entry.config, date: entry.date)
            case .systemMedium:
                PinnedScheduleWidgetMediumView(config: entry.config, date: entry.date)
            case .systemLarge:
                PinnedScheduleWidgetLargeView(config: entry.config, date: entry.date)
            case .systemExtraLarge:
                EmptyView()
            case .accessoryCircular:
                PinnedScheduleWidgetCircularView(config: entry.config)
            case .accessoryRectangular:
                PinnedScheduleWidgetRectangularView(config: entry.config)
            case .accessoryInline:
                PinnedScheduleWidgetInlineView(config: entry.config)
            @unknown default:
                EmptyView()
            }
        }
        .widgetURL(entry.config.deeplink)
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview("Pinned Schedule", as: .systemSmall) {
    PinnedScheduleWidget()
} timeline: {
    let entry = PinnedScheduleEntry.widgetPreview
    return [
        entry,
        mutating(entry) { $0.config.content = .pairs() },
        mutating(entry) { $0.config.content = .needsConfiguration },
        mutating(entry) { $0.config.content = .noPinned }
    ]
}
