import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import BsuirCore
import Combine

final class Provider: IntentTimelineProvider, ObservableObject {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> Entry {
        ScheduleEntry(date: Date(), title: "Some name", pairs: [])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        guard let identifier = ScheduleIdentifier(configuration: configuration) else {
            return completion(Entry(date: Date(), title: "---", pairs: []))
        }

        requestSnapshotCancellable = mostRelevantSchedule(for: identifier)
            .map { response in Entry(response, at: Date()) }
            .replaceNil(with: Entry(date: Date(), title: "---", pairs: []))
            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
            .sink(receiveValue: completion)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let identifier = ScheduleIdentifier(configuration: configuration) else {
            return completion(.init(entries: [Entry(date: Date(), title: "---", pairs: [])], policy: .never))
        }

        requestTimelineCancellable = mostRelevantSchedule(for: identifier)
            .map { Timeline<Entry>($0) }
            .replaceError(with: .init(entries: [], policy: .after(Date().advanced(by: 5 * 60))))
            .sink(receiveValue: completion)
    }

    fileprivate struct MostRelevantScheduleResponse {
        let title: String
        let schedule: WeekSchedule.ScheduleElement
    }

    private func mostRelevantSchedule(for identifier: ScheduleIdentifier) -> AnyPublisher<MostRelevantScheduleResponse, RequestsManager.RequestError> {
        requestSchedule(for: identifier)
            .compactMap { [calendar] response in
                let now = Date()

                guard let mostRelevantElement = WeekSchedule(schedule: response.schedules, calendar: calendar)
                        .schedule(starting: now, now: now)
                        .first(where: { $0.hasUnfinishedPairs(calendar: calendar, now: now) })
                else { return nil }

                return MostRelevantScheduleResponse(
                    title: response.title,
                    schedule: mostRelevantElement
                )
            }
            .eraseToAnyPublisher()
    }

    private struct ScheduleResponse {
        let title: String
        let schedules: [DaySchedule]
    }

    private enum ScheduleIdentifier {
        case group(id: Int)
        case lecturer(id: Int)

        init?(configuration: ConfigurationIntent) {
            func makeId(_ identifier: String?) -> Int? { identifier.flatMap(Int.init) }
            switch configuration.type {
            case .unknown, .group:
                guard let groupId = makeId(configuration.groupNumber?.identifier) else { return nil }
                self = .group(id: groupId)
            case .lecturer:
                guard let lecturerId = makeId(configuration.lecturer?.identifier) else { return nil }
                self = .lecturer(id: lecturerId)
            }
        }
    }

    private func requestSchedule(for identifier: ScheduleIdentifier) -> AnyPublisher<ScheduleResponse, RequestsManager.RequestError> {
        switch identifier {
        case let .group(groupId):
            return requestManager
                .request(BsuirTargets.Schedule(agent: .groupID(groupId)))
                .map { ScheduleResponse(title: $0.studentGroup.name, schedules: $0.schedules) }
                .eraseToAnyPublisher()
        case let .lecturer(lecturerId):
            return requestManager
                .request(BsuirTargets.EmployeeSchedule(id: lecturerId))
                .map { ScheduleResponse(title: $0.employee.abbreviatedName, schedules: $0.schedules ?? []) }
                .eraseToAnyPublisher()
        }
    }

    private let calendar = Calendar.current
    private var requestSnapshotCancellable: AnyCancellable?
    private var requestTimelineCancellable: AnyCancellable?
    private let requestManager = RequestsManager.bsuir()
}

private extension Employee {
    var abbreviatedName: String {
        let abbreviation = [firstName, middleName].compactMap { $0.first }.map { String($0).capitalized }.joined()
        return [lastName, abbreviation].filter { !$0.isEmpty }.joined(separator: " ")
    }
}

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

struct ScheduleEntry: TimelineEntry {
    typealias Pair = PairViewModel
    let date: Date
    var title: String
    var pairs: [Pair]
}

private extension ScheduleEntry {
    init?(_ response: Provider.MostRelevantScheduleResponse, at date: Date) {
        let remainingPairs = response.schedule.pairs.drop(while: { $0.end <= date })
        guard !remainingPairs.isEmpty else { return nil }
        self.init(
            date: date,
            title: response.title,
            pairs: remainingPairs.map {
                Pair(
                    $0.base,
                    showWeeks: false,
                    progress: PairProgress(at: date, pair: $0)
                )
            }
        )
    }
}

private extension Timeline where EntryType == ScheduleEntry {
    init(_ response: Provider.MostRelevantScheduleResponse) {
        let dates = response.schedule.pairs.flatMap { pair in
            stride(
                from: pair.start.timeIntervalSince1970,
                through: pair.end.timeIntervalSince1970,
                by: 10 * 60
            ).map { Date(timeIntervalSince1970: $0) }
        }

        self.init(
            entries: dates.compactMap { ScheduleEntry(response, at: $0) },
            policy: .atEnd
        )
    }
}

private extension PairProgress {
    convenience init(at date: Date, pair: WeekSchedule.ScheduleElement.Pair) {
        self.init(constant: Self.progress(at: date, from: pair.start, to: pair.end))
    }
}

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
        HStack {
            Spacer()
            Text("Нет занятий").foregroundColor(.secondary)
            Spacer()
        }
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
    let pairs: ArraySlice<Provider.Entry.Pair>
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

struct ScheduleWidgetEntrySmallView : View {
    var entry: Provider.Entry
    var currentPair: Provider.Entry.Pair? { entry.pairs.first }
    var remainingPairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.dropFirst() }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                ScheduleIdentifierTitle(title: entry.title)
                Spacer(minLength: 0)
            }

            WidgetDateTitle(date: entry.date)

            Spacer(minLength: 0)

            if let pair = currentPair {
                PairView(pair: pair, distribution: .vertical, isCompact: true)
            } else {
                NoPairsView()
            }

            Spacer(minLength: 0)

            RemainingPairs(pairs: remainingPairs, visibleCount: 1, showTime: false)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}

struct ScheduleWidgetEntryMediumView : View {
    var entry: Provider.Entry
    var visiblePairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.prefix(2) }
    var remainingPairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.dropFirst(2) }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                WidgetDateTitle(date: entry.date)
                Spacer()
                ScheduleIdentifierTitle(title: entry.title)
            }

            if visiblePairs.isEmpty {
                Spacer(minLength: 4)
                NoPairsView()
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(visiblePairs.indices, id: \.self) {
                        PairView(pair: visiblePairs[$0], isCompact: true)
                    }
                }
                .padding(.top, 6)
            }

            Spacer(minLength: 0)

            RemainingPairs(pairs: remainingPairs, visibleCount: 3, showTime: true)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct ScheduleWidgetEntryLargeView : View {
    var entry: Provider.Entry
    var visiblePairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.prefix(6) }
    var remainingPairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.dropFirst(6) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                WidgetDateTitle(date: entry.date)
                Spacer()
                ScheduleIdentifierTitle(title: entry.title)
            }

            if visiblePairs.isEmpty {
                Spacer(minLength: 0)
                NoPairsView()
            } else {
                VStack(alignment: .leading, spacing: 04) {
                    ForEach(visiblePairs.indices, id: \.self) {
                        PairView(pair: visiblePairs[$0], isCompact: true)
                            .padding(.leading, 10)
                            .padding(.vertical, 4)
                            .background(ContainerRelativeShape().foregroundColor(Color(.secondarySystemBackground)))
                    }
                }
                .padding(.vertical, 6)
            }

            Spacer(minLength: 0)

            RemainingPairs(pairs: remainingPairs, visibleCount: 3, showTime: true)
                .padding(.leading, 10)
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
        case .systemLarge:
            ScheduleWidgetEntryLargeView(entry: entry)
        @unknown default:
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
        .configurationDisplayName("Расписание")
        .description("Наиболее актуальное расписание для группы или преподавателя.")
    }
}

struct ScheduleWidget_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.pairs = [] })
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.pairs = Array($0.pairs.prefix(1)) })
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.pairs = [] })
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))

        ScheduleWidgetEntryView(entry: mutating(entry) { $0.pairs = [] })
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }

    static let entry = ScheduleEntry(
        date: Date().addingTimeInterval(3600 * 20),
        title: "Иванов АН",
        pairs: [
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Миапр", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Физра", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "ПОИТ", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "ОкПрог", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
        ]
    )
}
