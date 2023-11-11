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

struct OnlyExamsScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetService.Timeline.onlyExamsSchedule.rawValue,
            provider: ExamsScheduleProvider(onlyExams: true)
        ) { entry in
            ExamsScheduleWidgetEntryView(entry: entry)
                .environmentObject({
                    @Dependency(\.pairFormDisplayService) var pairFormDisplayService
                    return pairFormDisplayService
                }())
        }
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
        .configurationDisplayName("widget.onlyExams.displayName")
        .description("widget.onlyExams.description")
    }

    private let supportedFamilies: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge,
    ]
}

struct ExamsScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetService.Timeline.examsSchedule.rawValue,
            provider: ExamsScheduleProvider(onlyExams: false)
        ) { entry in
            ExamsScheduleWidgetEntryView(entry: entry)
                .environmentObject({
                    @Dependency(\.pairFormDisplayService) var pairFormDisplayService
                    return pairFormDisplayService
                }())
        }
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
        .configurationDisplayName("widget.exams.displayName")
        .description("widget.exams.description")
    }

    private let supportedFamilies: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge,
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
            case .systemLarge:
                ExamsScheduleWidgetLargeView(config: entry.config)
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
    let entry = ExamsScheduleEntry.preview(onlyExams: false)
    entry
    mutating(entry) { $0.config.content = .exams() }
    mutating(entry) { $0.config = .noSchedule(title: "151004", subgroup: 100) }
    mutating(entry) { $0.config = .noPinned() }
}

@available(iOS 17, *)
#Preview("Only Exams Schedule", as: .systemSmall) {
    OnlyExamsScheduleWidget()
} timeline: {
    let entry = ExamsScheduleEntry.preview(onlyExams: true)
    entry
    mutating(entry) { $0.config.content = .exams() }
    mutating(entry) { $0.config = .noSchedule(title: "151004", subgroup: 100) }
    mutating(entry) { $0.config = .noPinned() }
}
