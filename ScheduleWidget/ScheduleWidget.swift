import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import Combine

final class Provider: IntentTimelineProvider, ObservableObject {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> Entry {
        ScheduleEntry(date: Date(), title: "Some name", pairs: [])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        requestSnapshotCancellable = requestSchedule(for: configuration)
            .map { Entry(date: Date(), title: $0.title, pairs: []) }
            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
            .sink(receiveValue: completion)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        requestSnapshotCancellable = requestSchedule(for: configuration)
            .map { Entry(date: Date(), title: $0.title, pairs: []) }
            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
            .map { .init(entries: [$0], policy: .atEnd) }
            .sink(receiveValue: completion)
    }

    private struct ScheduleResponse {
        let title: String
        let schedules: [DaySchedule]
    }

    private enum RequestScheduleError: Error {
        case invalidData
        case request(RequestsManager.RequestError)
    }

    private func requestSchedule(for configuration: ConfigurationIntent) -> AnyPublisher<ScheduleResponse, RequestScheduleError> {
        func makeId(_ identifier: String?) -> Int? { identifier.flatMap(Int.init) }
        let fail = Fail<ScheduleResponse, RequestScheduleError>(error: .invalidData).eraseToAnyPublisher()
        switch configuration.type {
        case .unknown, .group:
            guard let groupId = makeId(configuration.groupNumber?.identifier) else { return fail }
            return requestManager
                .request(BsuirTargets.Schedule(agent: .groupID(groupId)))
                .mapError(RequestScheduleError.request)
                .map { ScheduleResponse(title: $0.studentGroup.name, schedules: $0.schedules) }
                .eraseToAnyPublisher()
        case .lecturer:
            guard let lecturerId = makeId(configuration.lecturer?.identifier) else { return fail }
            return requestManager
                .request(BsuirTargets.EmployeeSchedule(id: lecturerId))
                .mapError(RequestScheduleError.request)
                .map { ScheduleResponse(title: $0.employee.fio, schedules: $0.schedules ?? []) }
                .eraseToAnyPublisher()
        }
    }

    private var requestSnapshotCancellable: AnyCancellable?
    private var requestTimelineCancellable: AnyCancellable?
    private let requestManager = RequestsManager.bsuir()
}

private let listFormatter = mutating(ListFormatter()) { $0.locale = Locale(identifier: "ru_BY") }

private extension ListFormatter {
    func string<C: Collection>(from values: C, visibleCount: Int) -> String? {
        let visible = values.prefix(visibleCount).map { $0 as Any }
        let remaining = values.count - visibleCount
        guard remaining > 0 else { return string(from: visible) }
        return string(from: visible + ["еще \(remaining)"])
    }
}

struct ScheduleEntry: TimelineEntry {
    struct Pair {
        let from: String
        let to: String
        let title: String
        let subtitle: String
    }
    let date: Date
    let title: String
    let pairs: [Pair]
}

struct ScheduleWidgetEntrySmallView : View {
    var entry: Provider.Entry
    var pair: Provider.Entry.Pair { entry.pairs.first! }
    var pairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.dropFirst() }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image("BsuirSymbol").resizable().scaledToFit().frame(width: 20, height: 20)
                Text(entry.title).font(.subheadline).lineLimit(1)
                Spacer()
            }

            Text("Сегодня 24.09").font(.headline).foregroundColor(.blue)
            PairView(
                from: pair.from,
                to: pair.to,
                subject: pair.title,
                subgroup: "1",
                auditory: pair.subtitle,
                note: "asasasas as asas",
                form: .lecture,
                progress: PairProgress(constant: 0.5),
                distribution: .vertical,
                isCompact: true
            )

            if !pairs.isEmpty {
                HStack {
                    Circle().frame(width: 8, height: 8)
                    Text(listFormatter.string(from: pairs.map { $0.title }, visibleCount: 1) ?? "")
                        .font(.footnote)
                }.foregroundColor(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}

struct ScheduleWidgetEntryMediumView : View {
    var entry: Provider.Entry
    var pair: Provider.Entry.Pair { entry.pairs.first! }
    var pairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.dropFirst() }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("Сегодня, 24.09").font(.headline).foregroundColor(.blue)
                Spacer()
                Image("BsuirSymbol").resizable().scaledToFit().frame(width: 20, height: 20)
                Text(entry.title).font(.subheadline).lineLimit(1)
            }

            Spacer().frame(height: 4)


            VStack(alignment: .leading, spacing: 4) {

                PairView(
                    from: pair.from,
                    to: pair.to,
                    subject: pair.title,
                    subgroup: "1",
                    auditory: pair.subtitle,
                    note: "asasasas as asas",
                    form: .lecture,
                    progress: PairProgress(constant: 0.5),
                    isCompact: true
                )

                PairView(
                    from: pair.from,
                    to: pair.to,
                    subject: pair.title,
                    subgroup: "1",
                    auditory: pair.subtitle,
                    note: "asasasas as asas",
                    form: .lecture,
                    progress: PairProgress(constant: 0.5),
                    isCompact: true
                )

                if !pairs.isEmpty {
                    HStack {
                        Text("12:00").font(.system(.footnote, design: .monospaced))
                        Circle().frame(width: 8, height: 8)
                        Text(listFormatter.string(from: pairs.map { $0.title }, visibleCount: 3) ?? "")
                            .font(.footnote)
                    }.foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.systemBackground))
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
        default:
            EmptyView()
        }
    }
}

@main
struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"
    @StateObject var provider = Provider()

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: provider) { entry in
            ScheduleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ScheduleWidget_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .colorScheme(.dark)

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }

    static let entry = ScheduleEntry(
        date: Date(),
        title: "010102",
        pairs: [
            .init(from: "10:00", to: "11:45", title: "Философ", subtitle: "101-2"),
            .init(from: "10:00", to: "11:45", title: "Миапр", subtitle: "101-2"),
            .init(from: "10:00", to: "11:45", title: "Физра", subtitle: "101-2"),
            .init(from: "10:00", to: "11:45", title: "ПОИТ", subtitle: "101-2"),
            .init(from: "10:00", to: "11:45", title: "ОкПрог", subtitle: "101-2"),
            .init(from: "10:00", to: "11:45", title: "Философ", subtitle: "101-2")
        ]
    )
}
