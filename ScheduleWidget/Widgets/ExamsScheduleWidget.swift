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

struct ExamsScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetService.Timeline.examsSchedule.rawValue,
            provider: ExamsScheduleProvider()
        ) { entry in
            ExamsScheduleWidgetEntryView(entry: entry)
                .environmentObject({
                    @Dependency(\.pairFormDisplayService) var pairFormDisplayService
                    return pairFormDisplayService
                }())
        }
        .configurationDisplayName("widget.exams.displayName")
        .supportedFamilies(supportedFamilies)
        .description("widget.exams.description")
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

struct ExamsScheduleWidgetEntryView: View {
    let entry: ScheduleEntry
    @Environment(\.widgetFamily) var size

    var body: some View {
        Text("Nothing to look for here")
            .widgetURL(entry.config.deeplink)
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview("Exams Schedule", as: .systemSmall) {
    ExamsScheduleWidget()
} timeline: {
    let entry = ScheduleEntry.widgetPreview
    return [
        entry,
        mutating(entry) { $0.config.content = .pairs() },
        mutating(entry) { $0.config.content = .needsConfiguration },
        mutating(entry) { $0.config.content = .noPinned }
    ]
}
