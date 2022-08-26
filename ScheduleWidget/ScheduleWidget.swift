import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import BsuirCore
import Combine
import StoreKit

@main
struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"
    @StateObject var provider = Provider()

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: provider) { entry in
            ScheduleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget.displayName")
        .description("widget.description")
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
            @unknown default:
                EmptyView()
            }
        }
        .widgetURL(entry.deeplink?.rawValue)
    }
}

// MARK: - Small Widget UI
struct ScheduleWidgetEntrySmallView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                ScheduleIdentifierTitle(title: entry.title)
                Spacer(minLength: 0)
            }

            WidgetDateTitle(date: entry.date, isSmall: true)

            switch entry.content {
            case .needsConfiguration:
                NeedsConfigurationView()
            case .pairs(_, []):
                NoPairsView()
            case let .pairs(passed, upcoming):
                let pairs = pairsToDisplay(
                    passed: passed,
                    upcoming: upcoming,
                    maxVisibleCount: 1
                )

                Spacer(minLength: 0)
                ForEach(pairs.visible) { pair in
                    PairView(pair: pair, distribution: .vertical, isCompact: true)
                }
                Spacer(minLength: 0)

                RemainingPairs(pairs: pairs.upcomingInvisible, visibleCount: 1, showTime: .hide)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - Medium Widget UI
struct ScheduleWidgetEntryMediumView : View {
    var entry: Provider.Entry

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
            case .pairs(_, []):
                NoPairsView()
            case let .pairs(passed, upcoming):
                let pairs = pairsToDisplay(
                    passed: passed,
                    upcoming: upcoming,
                    maxVisibleCount: 2
                )

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(pairs.visible) { pair in
                        PairView<EmptyView>(pair: pair, isCompact: true)
                    }
                }
                .padding(.top, 6)

                Spacer(minLength: 0)

                RemainingPairs(pairs: pairs.upcomingInvisible, visibleCount: 3, showTime: .first)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Large Widget UI
struct ScheduleWidgetEntryLargeView : View {
    var entry: Provider.Entry

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
            case .pairs(_, []):
                NoPairsView()
            case let .pairs(passed, upcoming):
                let pairs = pairsToDisplay(
                    passed: passed,
                    upcoming: upcoming,
                    maxVisibleCount: 6
                )

                VStack(alignment: .leading, spacing: 4) {
                    RemainingPairs(pairs: pairs.passedInvisible, visibleCount: 3, showTime: .last)
                        .padding(.leading, 10)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(pairs.visible) { pair in
                            PairView<EmptyView>(pair: pair, isCompact: true)
                                .padding(.leading, 10)
                                .padding(.vertical, 2)
                                .background(ContainerRelativeShape().foregroundColor(Color(.secondarySystemBackground)))
                        }
                    }

                    Spacer(minLength: 0)

                    RemainingPairs(pairs: pairs.upcomingInvisible, visibleCount: 3, showTime: .first)
                        .padding(.leading, 10)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Fetch pairs
private func pairsToDisplay(
    passed: [PairViewModel],
    upcoming: [PairViewModel],
    maxVisibleCount: Int
) -> (
    passedInvisible: ArraySlice<PairViewModel>,
    visible: ArraySlice<PairViewModel>,
    upcomingInvisible: ArraySlice<PairViewModel>
) {
    let passedVisibleCount = maxVisibleCount - upcoming.count
    guard passedVisibleCount > 0 else {
        let splitIndex = upcoming.index(upcoming.startIndex, offsetBy: maxVisibleCount, boundedBy: upcoming.endIndex)
        return (passed[...], upcoming[..<splitIndex], upcoming[splitIndex...])
    }
    let splitIndex = passed.index(passed.endIndex, offsetBy: -passedVisibleCount, boundedBy: passed.startIndex)
    return (passed[..<splitIndex], passed[splitIndex...] + upcoming, [])
}

private extension Array {
    func index(_ index: Index, offsetBy offset: Int, boundedBy bound: Index) -> Index {
        self.index(index, offsetBy: offset, limitedBy: bound) ?? bound
    }
}

// MARK: - Formatters

private let listFormatter = ListFormatter()

private let smallDateFormatter = mutating(DateFormatter()) {
    $0.setLocalizedDateFormatFromTemplate("dE")
}

private let normalDateFormatter = mutating(DateFormatter()) {
    $0.setLocalizedDateFormatFromTemplate("dEMM")
}

private extension ListFormatter {
    func string<C: Collection>(from values: C, visibleCount: Int) -> String? {
        let visible = values.prefix(visibleCount).map { $0 as Any }
        let remaining = values.count - visibleCount
        guard remaining > 0 else { return string(from: visible) }
        return string(from: visible + [String(localized: "widget.schedule.more.\(remaining)")])
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
        Text("widget.schedule.empty")
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct NeedsConfigurationView: View {
    var body: some View {
        Text("widget.needsConfiguration.selectSchedule")
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct WidgetDateTitle: View {
    let date: Date
    var isSmall: Bool = false

    var body: some View {
        dateTitle
            .lineLimit(1)
            .allowsTightening(true)
            .environment(\.locale, .current)
    }

    var dateTitle: Text {
        Text((isSmall ? smallDateFormatter : normalDateFormatter).string(from: date))
    }
}

struct RemainingPairs: View {
    enum ShowTime {
        case first
        case last
        case hide
    }

    let pairs: ArraySlice<PairViewModel>
    let visibleCount: Int
    let showTime: ShowTime

    var body: some View {
        if !pairs.isEmpty {
            HStack {

                time.map(Text.init).font(.system(.footnote, design: .monospaced))

                Circle().frame(width: 8, height: 8)

                Text(listFormatter.string(from: pairs.map { $0.subject }, visibleCount: visibleCount) ?? "")
                    .font(.footnote)
            }
            .foregroundColor(.secondary)
        }
    }

    private var time: String? {
        switch showTime {
        case .first:
            return pairs.first?.from
        case .last:
            return pairs.last?.from
        case .hide:
            return nil
        }
    }
}

// MARK: - Previews

struct ScheduleWidget_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .pairs() })
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .pairs() })
            .previewContext(WidgetPreviewContext(family: .systemMedium))


        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.content = .pairs() })
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }

    static let entry = ScheduleEntry(
        date: Date().addingTimeInterval(3600 * 20),
        title: "Иванов АН",
        content: .pairs(
            passed: [
                .init(from: "10:00", to: "11:45", form: .practice, subject: "Миапр1", auditory: "101-2"),
                .init(from: "10:05", to: "11:45", form: .practice, subject: "Философ1", auditory: "101-2"),
                .init(from: "10:10", to: "11:45", form: .practice, subject: "Миапр1", auditory: "101-2"),
            ],
            upcoming: [
                .init(from: "10:15", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
                .init(from: "10:20", to: "11:45", form: .lecture, subject: "Миапр", auditory: "101-2"),
                .init(from: "10:25", to: "11:45", form: .lecture, subject: "Физра", auditory: "101-2"),
                .init(from: "10:30", to: "11:45", form: .lecture, subject: "ПОИТ", auditory: "101-2"),
                .init(from: "10:35", to: "11:45", form: .lecture, subject: "ОкПрог", auditory: "101-2"),
                .init(from: "10:40", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
                .init(from: "10:45", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
            ]
        )
    )
}
