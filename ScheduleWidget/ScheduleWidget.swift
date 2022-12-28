import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import BsuirCore
import ScheduleCore
import Combine
import StoreKit

@main
struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"
    @StateObject var provider = Provider()

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: provider) { entry in
            ScheduleWidgetEntryView(entry: entry)
                .environmentObject(PairFormColorService(storage: .asiliukShared))
        }
        .configurationDisplayName("widget.displayName")
        .supportedFamilies(supportedFamilies)
        .description("widget.description")
    }
    
    private var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [
            .systemSmall,
            .systemMedium,
            .systemLarge
        ]

        if #available(iOS 16.0, *) {
            families += [
                .accessoryCircular,
                .accessoryRectangular
            ]
        }
        
        return families
    }
}

struct ScheduleWidgetEntryView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var size

    var body: some View {
        Group {
            switch size {
            case .systemSmall:
                ScheduleWidgetEntrySmallView(entry: entry)
            case .systemMedium:
                ScheduleWidgetEntryMediumView(entry: entry)
            case .systemLarge:
                ScheduleWidgetEntryLargeView(entry: entry)
            case .systemExtraLarge:
                EmptyView()
            case .accessoryCircular:
                if #available(iOS 16.0, *) {
                    ScheduleWidgetEntryAccessoryCircularView(entry: entry)
                }
            case .accessoryRectangular:
                if #available(iOS 16.0, *) {
                    ScheduleWidgetEntryAccessoryRectangularView(entry: entry)
                }
            case .accessoryInline:
                /// Not yet supported
                EmptyView()
            @unknown default:
                EmptyView()
            }
        }
        .widgetURL(entry.deeplink)
    }
}

// MARK: - Previews

struct ScheduleWidget_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleWidgetEntryView(entry: entry)
            .previewDisplayName("Schedule")
            .previewContext(WidgetPreviewContext(family: family))
        
        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .pairs() })
            .previewContext(WidgetPreviewContext(family: family))
            .previewDisplayName("No Pairs")
        
        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .needsConfiguration })
            .previewContext(WidgetPreviewContext(family: family))
            .previewDisplayName("No Configuration")
    }
    
    static var family: WidgetFamily {
        return .systemSmall
    }

    static let entry = ScheduleEntry(
        date: Date().addingTimeInterval(3600 * 20),
        title: "Иванов АН",
        content: .pairs(
            passed: [
                .init(from: "10:00", to: "11:45", interval: "10:00-11:45", form: .practice, subject: "Миапр1", auditory: "101-2"),
                .init(from: "10:05", to: "11:45", interval: "10:05-11:45", form: .practice, subject: "Философ1", auditory: "101-2"),
                .init(from: "10:10", to: "11:45", interval: "10:10-11:45", form: .practice, subject: "Миапр1", auditory: "101-2"),
            ],
            upcoming: [
                .init(from: "10:15", to: "11:45", interval: "10:15-11:45", form: .lecture, subject: "Философ", auditory: "101-2", progress: .init(constant: 0.35)),
                .init(from: "10:20", to: "11:45", interval: "10:20-11:45", form: .lecture, subject: "Миапр", auditory: "101-2"),
                .init(from: "10:25", to: "11:45", interval: "10:25-11:45", form: .lecture, subject: "Физра", auditory: "101-2"),
                .init(from: "10:30", to: "11:45", interval: "10:30-11:45", form: .lecture, subject: "ПОИТ", auditory: "101-2"),
                .init(from: "10:35", to: "11:45", interval: "10:35-11:45", form: .lecture, subject: "ОкПрог", auditory: "101-2"),
                .init(from: "10:40", to: "11:45", interval: "10:40-11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
                .init(from: "10:45", to: "11:45", interval: "10:45-11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
            ]
        )
    )
}
