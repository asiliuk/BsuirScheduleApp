import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import BsuirCore
import Combine

@main
struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"
    @StateObject var provider = Provider()

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: provider) { entry in
            ScheduleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Расписание")
        .description("Наиболее актуальное расписание для группы или преподавателя.")
    }
}

struct ScheduleWidgetEntryView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var size

    var body: some View {
        switch size {
        case .systemSmall:
            ScheduleWidgetEntrySmallView(entry: entry)
        case .systemMedium:
            ScheduleWidgetEntryMediumView(entry: entry)
        case .systemLarge:
            ScheduleWidgetEntryLargeView(entry: entry)
        @unknown default:
            EmptyView()
        }
    }
}

// MARK: - Widget UI

struct ScheduleWidgetEntrySmallView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                ScheduleIdentifierTitle(title: entry.title)
                Spacer(minLength: 0)
            }

            WidgetDateTitle(date: entry.date)

            switch entry.content {
            case .needsConfiguration:
                NeedsConfigurationView()
            case .pairs([]):
                NoPairsView()
            case let .pairs(pairs):
                Spacer(minLength: 0)
                PairView(pair: pairs[0], distribution: .vertical, isCompact: true)
                Spacer(minLength: 0)

                RemainingPairs(pairs: pairs.dropFirst(), visibleCount: 1, showTime: false)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}

struct ScheduleWidgetEntryMediumView : View {
    var entry: Provider.Entry
    let visiblePairsCount = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                WidgetDateTitle(date: entry.date)
                Spacer()
                ScheduleIdentifierTitle(title: entry.title)
            }

            switch entry.content {
            case .needsConfiguration:
                NeedsConfigurationView()
            case .pairs([]):
                NoPairsView()
            case let .pairs(pairs):
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(pairs.indices.prefix(visiblePairsCount), id: \.self) {
                        PairView(pair: pairs[$0], isCompact: true)
                    }
                }
                .padding(.top, 6)

                Spacer(minLength: 0)

                RemainingPairs(pairs: pairs.dropFirst(visiblePairsCount), visibleCount: 3, showTime: true)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct ScheduleWidgetEntryLargeView : View {
    var entry: Provider.Entry
    let visiblePairsCount = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                WidgetDateTitle(date: entry.date)
                Spacer()
                ScheduleIdentifierTitle(title: entry.title)
            }

            switch entry.content {
            case .needsConfiguration:
                NeedsConfigurationView()
            case .pairs([]):
                NoPairsView()
            case let .pairs(pairs):
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(pairs.indices.prefix(visiblePairsCount), id: \.self) {
                        PairView(pair: pairs[$0], isCompact: true)
                            .padding(.leading, 10)
                            .padding(.vertical, 4)
                            .background(ContainerRelativeShape().foregroundColor(Color(.secondarySystemBackground)))
                    }
                }
                .padding(.vertical, 6)

                Spacer(minLength: 0)

                RemainingPairs(pairs: pairs.dropFirst(visiblePairsCount), visibleCount: 3, showTime: true)
                    .padding(.leading, 10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}


// MARK: - Formatters

private let listFormatter = mutating(ListFormatter()) {
    $0.locale = .by
}

private let dateFormatter = mutating(DateFormatter()) {
    $0.locale = .by
    $0.setLocalizedDateFormatFromTemplate("dMM")
}

private let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()

private extension ListFormatter {
    func string<C: Collection>(from values: C, visibleCount: Int) -> String? {
        let visible = values.prefix(visibleCount).map { $0 as Any }
        let remaining = values.count - visibleCount
        guard remaining > 0 else { return string(from: visible) }
        return string(from: visible + ["еще \(remaining)"])
    }
}

// MARK: - Helper UI

struct ScheduleIdentifierTitle: View {
    let title: String

    var body: some View {
        HStack {
            Image("BsuirSymbol").resizable().scaledToFit().frame(width: 20, height: 20)
            Text(title).font(.subheadline).lineLimit(1)
        }
    }
}

struct NoPairsView: View {
    var body: some View {
        Text("Нет занятий")
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct NeedsConfigurationView: View {
    var body: some View {
        Text("Выберите расписание")
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct WidgetDateTitle: View {
    let date: Date
    @Environment(\.calendar) var calendar

    var body: some View {
        ScheduleDateTitle(
            date: dateFormatter.string(from: date),
            relativeDate: relativeFormatter.relativeName(for: date, now: Date()),
            isToday: calendar.isDateInToday(date)
        )
    }
}

struct RemainingPairs: View {
    let pairs: ArraySlice<PairViewModel>
    let visibleCount: Int
    let showTime: Bool

    var body: some View {
        if !pairs.isEmpty {
            HStack {
                if showTime, let time = pairs.first?.from {
                    Text(time).font(.system(.footnote, design: .monospaced))
                }

                Circle().frame(width: 8, height: 8)

                Text(listFormatter.string(from: pairs.map { $0.subject }, visibleCount: visibleCount) ?? "")
                    .font(.footnote)
            }
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Previews

struct ScheduleWidget_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .pairs([]) })
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .needsConfiguration })
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .pairs([]) })
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .needsConfiguration })
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .pairs([]) })
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }

    static let entry = ScheduleEntry(
        date: Date().addingTimeInterval(3600 * 20),
        title: "Иванов АН",
        content: .pairs([
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Миапр", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Физра", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "ПОИТ", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "ОкПрог", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
        ])
    )
}
