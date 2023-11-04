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
        .contentMarginsDisabled()
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
    let entry: ExamsScheduleEntry
    @Environment(\.widgetFamily) var size
    @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

    var body: some View {
        Group {
            switch size {
            case .systemSmall:
                ExamsScheduleWidgetSmallView(config: entry.config)
            case .systemMedium:
                ExamsScheduleWidgetMediumView(config: entry.config)
            default:
                EmptyView()
            }
        }
        .widgetURL(entry.config.deeplink)
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview("Exams Schedule", as: .systemSmall) {
    ExamsScheduleWidget()
} timeline: {
    let entry = ExamsScheduleEntry.preview
    return [
        entry,
        mutating(entry) { $0.config.content = .exams() },
        mutating(entry) { $0.config.content = .noPinned }
    ]
}
